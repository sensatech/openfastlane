package at.sensatech.openfastlane.domain.consumptions

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.documents.exports.ExportLineItem
import at.sensatech.openfastlane.documents.exports.ExportSchema
import at.sensatech.openfastlane.documents.exports.XlsExporter
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibilityType
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsError
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.events.ConsumptionEvent
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.ConsumptionRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import at.sensatech.openfastlane.tracking.TrackingService
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime

@Service
class ConsumptionsServiceImpl(
    private val entitlementRepository: EntitlementRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val campaignRepository: CampaignRepository,
    private val personRepository: PersonRepository,
    private val consumptionRepository: ConsumptionRepository,
    private val xlsExporter: XlsExporter,
    private val trackingService: TrackingService,
) : ConsumptionsService {

    override fun getConsumption(user: OflUser, id: String): Consumption? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return consumptionRepository.findByIdOrNull(id)
    }

    override fun findConsumptions(
        user: OflUser,
        campaignId: String?,
        causeId: String?,
        personId: String?,
        from: LocalDate?,
        to: LocalDate?
    ): List<Consumption> {

        AdminPermissions.assertPermission(user, UserRole.READER)

        if (personId != null) {
            personRepository.findByIdOrNull(personId)
                ?: throw PersonsError.NotFoundException(personId)
        }

        val (finalFrom, finalTo) = checkParamsAndSetDuration(causeId, campaignId, from, to)

        return if (personId != null) {
            if (campaignId != null) {
                consumptionRepository.findByPersonIdAndCampaignIdAndConsumedAtIsBetweenOrderByConsumedAt(
                    personId = personId,
                    campaignId = campaignId,
                    from = finalFrom,
                    to = finalTo
                )
            } else {
                consumptionRepository.findByPersonIdAndConsumedAtIsBetweenOrderByConsumedAt(
                    personId = personId,
                    from = finalFrom,
                    to = finalTo
                )
            }
        } else {
            if (causeId != null) {
                consumptionRepository.findByEntitlementCauseIdAndConsumedAtIsBetweenOrderByConsumedAt(
                    causeId = causeId,
                    from = finalFrom,
                    to = finalTo
                )
            } else if (campaignId != null) {
                consumptionRepository.findByCampaignIdAndConsumedAtIsBetweenOrderByConsumedAt(
                    campaignId = campaignId,
                    from = finalFrom,
                    to = finalTo
                )
            } else {
                consumptionRepository.findByConsumedAtIsBetweenOrderByConsumedAt(
                    from = finalFrom,
                    to = finalTo
                )
            }
        }
    }

    fun getBeginningOfCurrentPeriod(period: Period, now: LocalDate): LocalDate {
        return when (period) {
            Period.ONCE -> LocalDate.of(2023, 1, 1)
            Period.YEARLY -> now.withDayOfYear(1).withDayOfMonth(1)
            Period.MONTHLY -> now.withDayOfMonth(1)
            Period.WEEKLY -> now.minusDays(now.dayOfWeek.value.toLong() - 1)
        }
    }

    override fun checkConsumptionPossibility(
        user: OflUser,
        personId: String,
        campaignId: String
    ): ConsumptionPossibility {

        AdminPermissions.assertPermission(user, UserRole.READER)

        val person = personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)
        val campaign = campaignRepository.findByIdOrNull(campaignId)
            ?: throw EntitlementsError.NoCampaignFound(campaignId)

        val entitlements = entitlementRepository.findByPersonId(person.id)
        val bestEntitlement = entitlements
            .filter { it.campaignId == campaign.id }
            .maxByOrNull { it.status.ordinal }
            ?: return ConsumptionPossibilityType.REQUEST_INVALID.transform()
        trackingService.track(ConsumptionEvent.Check(campaignId))

        return checkConsumptionPossibility(user, bestEntitlement.id).also {
            trackingService.track(ConsumptionEvent.CheckResult(campaignId, it.status.name))
        }
    }

    override fun checkConsumptionPossibility(user: OflUser, entitlementId: String): ConsumptionPossibility {

        AdminPermissions.assertPermission(user, UserRole.READER)

        val bestEntitlement = entitlementRepository.findByIdOrNull(entitlementId)
            ?: throw EntitlementsError.NoEntitlementFound(entitlementId)
        val campaign = campaignRepository.findByIdOrNull(bestEntitlement.campaignId)
            ?: return ConsumptionPossibility(ConsumptionPossibilityType.REQUEST_INVALID)

        val beginningOfCurrentPeriod = getBeginningOfCurrentPeriod(campaign.period, LocalDate.now())

        return when {
            bestEntitlement.status == EntitlementStatus.PENDING -> ConsumptionPossibilityType.ENTITLEMENT_INVALID.transform()
            bestEntitlement.status == EntitlementStatus.INVALID -> ConsumptionPossibilityType.ENTITLEMENT_INVALID.transform()
            bestEntitlement.status == EntitlementStatus.EXPIRED -> ConsumptionPossibilityType.ENTITLEMENT_EXPIRED.transform()
            else -> {
                val consumptions = findConsumptions(
                    user,
                    personId = bestEntitlement.personId,
                    causeId = bestEntitlement.entitlementCauseId,
                    campaignId = bestEntitlement.campaignId,
                    from = beginningOfCurrentPeriod,
                )

                val otherC =
                    consumptionRepository.findByEntitlementIdOrderByConsumedAt(bestEntitlement.entitlementCauseId)

                if (consumptions.isNotEmpty() && otherC.isEmpty()) {
                    ConsumptionPossibility(
                        status = ConsumptionPossibilityType.CONSUMPTION_ALREADY_DONE,
                        lastConsumptionAt = consumptions.maxByOrNull { it.consumedAt }?.consumedAt
                    )
                } else {
                    ConsumptionPossibilityType.CONSUMPTION_POSSIBLE.transform()
                }
            }
        }
    }

    override fun getConsumptionsOfEntitlement(user: OflUser, entitlementId: String): List<Consumption> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val entitlement = entitlementRepository.findByIdOrNull(entitlementId)
            ?: throw EntitlementsError.NoEntitlementFound(entitlementId)
        return consumptionRepository.findByEntitlementIdOrderByConsumedAt(entitlement.id)
    }

    override fun performConsumption(user: OflUser, personId: String, causeId: String): Consumption {

        AdminPermissions.assertPermission(user, UserRole.SCANNER)
        val person = personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)

        val cause = causeRepository.findByIdOrNull(causeId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(causeId)

        val campaign = campaignRepository.findByIdOrNull(cause.campaignId)
            ?: throw EntitlementsError.NoCampaignFound(cause.campaignId)

        val entitlements = entitlementRepository.findByPersonId(person.id)
        val bestEntitlement = entitlements
            .filter { it.campaignId == campaign.id }
            .maxByOrNull { it.status.ordinal }
            ?: throw EntitlementsError.NoEntitlementFound("personId $personId")

        return performConsumption(user, bestEntitlement.id)
    }

    override fun performConsumption(user: OflUser, entitlementId: String): Consumption {
        AdminPermissions.assertPermission(user, UserRole.SCANNER)

        val bestEntitlement = entitlementRepository.findByIdOrNull(entitlementId)
            ?: throw EntitlementsError.NoEntitlementFound(entitlementId)

        val possibility = checkConsumptionPossibility(user, bestEntitlement.id).status
        if (possibility != ConsumptionPossibilityType.CONSUMPTION_POSSIBLE) {
            if (possibility == ConsumptionPossibilityType.CONSUMPTION_ALREADY_DONE) {
                throw ConsumptionsError.AlreadyDoneError()
            } else {
                throw ConsumptionsError.NotPossibleError(possibility)
            }
        }
        val consumption = Consumption(
            id = newId(),
            personId = bestEntitlement.personId,
            entitlementCauseId = bestEntitlement.entitlementCauseId,
            entitlementId = bestEntitlement.id,
            campaignId = bestEntitlement.campaignId,
            consumedAt = ZonedDateTime.now(),
            entitlementData = bestEntitlement.values
        )

        val consumptionInfo = consumption.toConsumptionInfo()

        val person = personRepository.findByIdOrNull(bestEntitlement.personId)
            ?: throw PersonsError.NotFoundException(bestEntitlement.personId)

        person.lastConsumptions.removeAll { it.entitlementId == bestEntitlement.id }
        person.lastConsumptions.add(consumptionInfo)
        personRepository.save(person)

        trackingService.track(ConsumptionEvent.Consume(consumptionInfo.campaignId))

        return consumptionRepository.save(consumption)
    }

    override fun exportConsumptions(
        user: OflUser,
        campaignId: String?,
        causeId: String?,
        from: LocalDate?,
        to: LocalDate?
    ): FileResult? {

        AdminPermissions.assertPermission(user, UserRole.MANAGER)
        val (finalFrom, finalTo) = checkParamsAndSetDuration(causeId, campaignId, from, to)

        val consumptions = if (causeId != null) {
            consumptionRepository.findByEntitlementCauseIdAndConsumedAtIsBetweenOrderByConsumedAt(
                causeId = causeId,
                from = finalFrom,
                to = finalTo
            )
        } else if (campaignId != null) {
            consumptionRepository.findByCampaignIdAndConsumedAtIsBetweenOrderByConsumedAt(
                campaignId = campaignId,
                from = finalFrom,
                to = finalTo
            )
        } else {
            consumptionRepository.findByConsumedAtIsBetweenOrderByConsumedAt(
                from = finalFrom,
                to = finalTo
            )
        }

        val allCausesId: HashSet<String> = hashSetOf()
        val allPersonIds: HashSet<String> = hashSetOf()
        consumptions.forEach {
            allCausesId.add(it.entitlementCauseId)
            allPersonIds.add(it.personId)
        }
        val allPersons = personRepository.findAll()

        val consumingPersons: Map<String, Person> = allPersons
            .filter { it.id in allPersonIds }
            .associateBy { it.id }

        val lineItems = consumptions.mapNotNull {
            val person = consumingPersons[it.personId]
            if (person == null) {
                null
            } else {
                ExportLineItem(person, it)
            }
        }

        val allCauses = causeRepository.findAllById(allCausesId)
            .associateBy { it.id }

        val reportColumns = linkedMapOf<String, String>()
        allCauses.forEach { item ->
            val cause = item.value
            cause.criterias.filter { it.reportKey != null }.forEach { reportColumns[it.id] = it.reportKey!! }
        }

        val campaignNames = campaignRepository.findAll()
            .associateBy { it.id }
            .mapValues { it.value.name }
        val causeNames = allCauses.mapValues { it.value.name }

        val now = ZonedDateTime.now().toLocalDate().toString()
        val fromString = finalFrom.toLocalDate().toString()
        val toString = finalTo.toLocalDate().toString()
        val name = "export_${campaignId ?: ""}_${causeId ?: ""}_$fromString-${toString}_v$now.xlsx"
        val result = xlsExporter.export(
            ExportSchema(
                name = name,
                sheetName = "Export",
                campaignNames = campaignNames,
                causeNames = causeNames,
                reportColumns = reportColumns
            ),
            data = lineItems
        )

        trackingService.track(ConsumptionEvent.Export(name, lineItems.size))
        return result
    }

    private fun checkParamsAndSetDuration(
        causeId: String?,
        campaignId: String?,
        from: LocalDate?,
        to: LocalDate?
    ): Pair<ZonedDateTime, ZonedDateTime> {
        if (causeId != null) {
            causeRepository.findByIdOrNull(causeId)
                ?: throw EntitlementsError.NoEntitlementCauseFound(causeId)
        }

        if (campaignId != null) {
            campaignRepository.findByIdOrNull(campaignId)
                ?: throw EntitlementsError.NoCampaignFound(campaignId)
        }

        val finalFrom = if (from != null) {
            ZonedDateTime.of(from.atStartOfDay(), ZoneId.systemDefault()).withHour(0).withMinute(0).withSecond(0)
                .withNano(0)
        } else {
            ZonedDateTime.of(2024, 1, 1, 0, 0, 0, 0, ZoneId.systemDefault())
        }
        val finalTo = if (to != null) {
            ZonedDateTime.of(to.atStartOfDay(), ZoneId.systemDefault()).withHour(23).withMinute(59).withSecond(59)
                .withNano(0)
        } else {
            ZonedDateTime.now()
        }
        return Pair(finalFrom, finalTo)
    }
}
