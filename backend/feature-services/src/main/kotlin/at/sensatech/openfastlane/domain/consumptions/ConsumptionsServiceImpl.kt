package at.sensatech.openfastlane.domain.consumptions

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsError
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.ConsumptionRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.data.repository.findByIdOrNull
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime

class ConsumptionsServiceImpl(
    private val entitlementRepository: EntitlementRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val campaignRepository: CampaignRepository,
    private val personRepository: PersonRepository,
    private val consumptionRepository: ConsumptionRepository,
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
        from: ZonedDateTime?,
        to: ZonedDateTime?
    ): List<Consumption> {

        AdminPermissions.assertPermission(user, UserRole.READER)

        if (personId != null) {
            personRepository.findByIdOrNull(personId)
                ?: throw PersonsError.NotFoundException(personId)
        }

        if (causeId != null) {
            causeRepository.findByIdOrNull(causeId)
                ?: throw EntitlementsError.NoEntitlementCauseFound(causeId)
        }

        if (campaignId != null) {
            campaignRepository.findByIdOrNull(campaignId)
                ?: throw EntitlementsError.NoCampaignFound(campaignId)
        }

        val finalFrom = from?.withHour(0)?.withMinute(0)?.withSecond(0)?.withNano(0)
            ?: ZonedDateTime.of(2024, 1, 1, 0, 0, 0, 0, ZoneId.systemDefault())
        val finalTo = to?.withHour(23)?.withMinute(59)?.withSecond(59)?.withNano(0)
            ?: ZonedDateTime.now()

        return if (personId != null) {
            if (causeId != null) {
                consumptionRepository.findByPersonIdAndEntitlementCauseIdAndConsumedAtIsBetween(
                    personId = personId,
                    causeId = causeId,
                    from = finalFrom,
                    to = finalTo
                )
            } else {
                consumptionRepository.findByPersonIdAndConsumedAtIsBetween(
                    personId = personId,
                    from = finalFrom,
                    to = finalTo
                )
            }
        } else {
            if (causeId != null) {
                consumptionRepository.findByEntitlementCauseIdAndConsumedAtIsBetween(
                    causeId = causeId,
                    from = finalFrom,
                    to = finalTo
                )
            } else if (campaignId != null) {
                consumptionRepository.findByCampaignIdAndConsumedAtIsBetween(
                    campaignId = campaignId,
                    from = finalFrom,
                    to = finalTo
                )
            } else {
                consumptionRepository.findByConsumedAtIsBetween(
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
            ?: return ConsumptionPossibility.REQUEST_INVALID

        val beginningOfCurrentPeriod = getBeginningOfCurrentPeriod(campaign.period, LocalDate.now())

        return when {
            bestEntitlement.status == EntitlementStatus.INVALID -> ConsumptionPossibility.ENTITLEMENT_INVALID
            bestEntitlement.status == EntitlementStatus.EXPIRED -> ConsumptionPossibility.ENTITLEMENT_EXPIRED
            else -> {
                val consumptions = findConsumptions(
                    user,
                    personId = person.id,
                    causeId = bestEntitlement.entitlementCauseId,
                    campaignId = campaign.id,
                    from = beginningOfCurrentPeriod.atStartOfDay().atZone(ZoneId.systemDefault()),
                )

                if (consumptions.isNotEmpty()) {
                    ConsumptionPossibility.CONSUMPTION_ALREADY_DONE
                } else {
                    ConsumptionPossibility.CONSUMPTION_POSSIBLE
                }
            }
        }
    }

    override fun performConsumption(user: OflUser, personId: String, causeId: String): Consumption {
        val person = personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)

        val cause = causeRepository.findByIdOrNull(causeId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(causeId)

        val campaign = campaignRepository.findByIdOrNull(cause.campaignId)
            ?: throw EntitlementsError.NoCampaignFound(cause.campaignId)

        val entitlements = entitlementRepository.findByPersonId(personId)
        val bestEntitlement = entitlements
            .filter { it.campaignId == campaign.id }
            .maxByOrNull { it.status.ordinal }
            ?: throw EntitlementsError.NoEntitlementFound("personId $personId")

        val possibility = checkConsumptionPossibility(user, personId, campaign.id)
        if (possibility != ConsumptionPossibility.CONSUMPTION_POSSIBLE) {
            if (possibility == ConsumptionPossibility.CONSUMPTION_ALREADY_DONE) {
                throw ConsumptionsError.AlreadyDoneError()
            } else {
                throw ConsumptionsError.NotPossibleError(possibility)
            }
        }
        return consumptionRepository.save(
            Consumption(
                id = newId(),
                personId = personId,
                entitlementCauseId = causeId,
                campaignId = campaign.id,
                consumedAt = ZonedDateTime.now(),
                entitlementData = bestEntitlement.values
            )
        )
    }
}
