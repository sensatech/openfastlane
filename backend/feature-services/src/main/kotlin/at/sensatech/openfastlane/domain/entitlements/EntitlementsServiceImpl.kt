package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.documents.pdf.PdfGenerator
import at.sensatech.openfastlane.documents.pdf.PdfInfo
import at.sensatech.openfastlane.domain.config.RestConstantsService
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.logAudit
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.slf4j.LoggerFactory
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

@Service
class EntitlementsServiceImpl(
    private val entitlementRepository: EntitlementRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val campaignRepository: CampaignRepository,
    private val personRepository: PersonRepository,
    private val restConstantsService: RestConstantsService,
    private val pdfGenerator: PdfGenerator
) : EntitlementsService {

    private val dateFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

    override fun listAllEntitlements(user: OflUser): List<Entitlement> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return entitlementRepository.findAll()
    }

    override fun getEntitlement(user: OflUser, id: String): Entitlement? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return entitlementRepository.findByIdOrNull(id)
    }

    override fun getPersonEntitlements(user: OflUser, personId: String): List<Entitlement> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val person = personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)

        return entitlementRepository.findByPersonId(person.id)
    }

    override fun createEntitlement(user: OflUser, request: CreateEntitlement): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val personId = request.personId
        val entitlementCauseId = request.entitlementCauseId

        val entitlementCause = causeRepository.findByIdOrNull(entitlementCauseId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(entitlementCauseId)

        val person = personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)

        val entitlements = getPersonEntitlements(user, person.id)
        val matchingEntitlements = entitlements.filter { it.entitlementCauseId == entitlementCauseId }
        if (matchingEntitlements.isNotEmpty()) {
            throw EntitlementsError.PersonEntitlementAlreadyExists(matchingEntitlements.first().id)
        }

        val valueSet = entitlementCause.criterias.map { EntitlementValue(it.id, it.type, "") }

        val finalCreateValues = mergeValues(valueSet, request.values)
        val entitlement = Entitlement(
            id = newId(),
            personId = personId,
            campaignId = entitlementCause.campaignId,
            entitlementCauseId = entitlementCause.id,
            status = EntitlementStatus.PENDING,
            values = finalCreateValues.toMutableList(),
        )

        entitlement.audit.logAudit(user, "CREATED", "Angelegt mit ${request.values.size} Werten")

        val saved = entitlementRepository.save(entitlement)
        return saved
    }

    fun mergeValues(baseValues: List<EntitlementValue>, newValues: List<EntitlementValue>): List<EntitlementValue> {
        return baseValues.map { value ->
            val newValue = newValues.find { it.criteriaId == value.criteriaId }
            if (newValue != null) {
                EntitlementValue(value.criteriaId, value.type, newValue.value)
            } else {
                value
            }
        }
    }

    override fun updateEntitlement(user: OflUser, id: String, request: UpdateEntitlement): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = entitlementRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        val entitlementCause = causeRepository.findByIdOrNull(entitlement.entitlementCauseId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(entitlement.entitlementCauseId)

        val valueSet = entitlementCause.criterias.map {
            EntitlementValue(it.id, it.type, "")
        }

        val validCurrentValues = mergeValues(valueSet, entitlement.values)
        val patchedNewValues = mergeValues(validCurrentValues, request.values)
        entitlement.apply {
            updatedAt = ZonedDateTime.now()
            values = patchedNewValues.toMutableList()
        }

        val status = validateEntitlement(user, entitlement)
        entitlement.audit.logAudit(
            user,
            "UPDATED",
            "${request.values.size} Werte aktualisiert, alter Status: ${entitlement.status}, neu: $status"
        )
        entitlement.status = status
        val saved = entitlementRepository.save(entitlement)
        return saved
    }

    override fun extendEntitlement(user: OflUser, id: String): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = entitlementRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        campaignRepository.findByIdOrNull(entitlement.campaignId)
            ?: throw EntitlementsError.NoCampaignFound(entitlement.campaignId)

        val expandTime = expandForPeriod(ZonedDateTime.now())
        val oldExpiresAt = dateFormatter.format(entitlement.expiresAt ?: ZonedDateTime.now())
        val oldStatus = entitlement.status
        entitlement.apply {
            expiresAt = expandTime
            confirmedAt = ZonedDateTime.now()
            updatedAt = ZonedDateTime.now()
        }
        // call AFTER updating expiresAt
        val status = validateEntitlement(user, entitlement)
        entitlement.status = status
        entitlement.audit.logAudit(
            user,
            "EXTENDED",
            "Verlängert bis ${dateFormatter.format(expandTime)} (war $oldExpiresAt) mit Status $status (war $oldStatus)"
        )

        return entitlementRepository.save(entitlement)
    }

    fun validateEntitlement(user: OflUser, entitlement: Entitlement): EntitlementStatus {
        AdminPermissions.assertPermission(user, UserRole.READER)

        val cause = causeRepository.findByIdOrNull(entitlement.entitlementCauseId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(entitlement.entitlementCauseId)

        if (entitlement.expiresAt == null) {
            return EntitlementStatus.PENDING
        } else if (entitlement.expiresAt!!.isBefore(ZonedDateTime.now())) {
            return EntitlementStatus.EXPIRED
        }

        val values = entitlement.values

        cause.criterias.forEach { criterion ->
            val currentValue = values.find { it.criteriaId == criterion.id }
            if (currentValue == null || currentValue.invalid()    ) {
                log.error("Entitlement {} is missing criteria {}", entitlement.id, criterion.toString())
                return EntitlementStatus.INVALID
            } else {
                if (!checkCriteria(criterion, currentValue)) {
                    return EntitlementStatus.INVALID
                }
            }
        }
        return EntitlementStatus.VALID
    }

    /**
     * Attention: The time frame of periods is not a good indicator for expiration and expanding time.
     * We use 1 year as a default for now.
     */
    private fun expandForPeriod(dateTime: ZonedDateTime): ZonedDateTime {
        return dateTime.plusYears(1)
    }

    fun checkCriteria(criterion: EntitlementCriteria, currentValue: EntitlementValue): Boolean {
        val value = currentValue.value
        val criteriaId = currentValue.criteriaId

        if (value.isEmpty()) {
            log.error("Entitlement is missing value for criteria {} {}", currentValue.criteriaId, criterion.type)
            return false
        }
        if (criterion.type == EntitlementCriteriaType.OPTIONS && criterion.options != null) {
            val option = criterion.options!!.find { it.key == value }
            if (option == null) {
                log.error("Entitlement has invalid OPTIONS value for criteria {}", criteriaId)
                return false
            }
        }

        if (criterion.type == EntitlementCriteriaType.CHECKBOX) {
            if (value != "true" && value != "false") {
                log.error("Entitlement has invalid CHECKBOX value for criteria {}", criteriaId)
                return false
            }
        }

        if (criterion.type == EntitlementCriteriaType.INTEGER) {
            try {
                value.trim().toInt()
            } catch (e: NumberFormatException) {
                log.error("Entitlement has invalid INTEGER value for criteria {}", criteriaId)
                return false
            }
        }

        if (criterion.type == EntitlementCriteriaType.FLOAT || criterion.type == EntitlementCriteriaType.CURRENCY) {
            try {
                value.trim().toDouble()
            } catch (e: NumberFormatException) {
                log.error(
                    "Entitlement {} has invalid FLOAT value for criteria {}",
                    currentValue.criteriaId,
                    criteriaId
                )
                return false
            }
        }
        return true
    }

    override fun updateQrCode(user: OflUser, id: String): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = entitlementRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementFound(id)
        val entitlementStatus = validateEntitlement(user, entitlement)
        if (entitlementStatus != EntitlementStatus.VALID) {
            throw EntitlementsError.InvalidEntitlement(entitlementStatus.toString())
        }

        val now = ZonedDateTime.now()
        val stringId = getQrCode(entitlement, now)

        return entitlementRepository.save(
            entitlement.apply {
                code = stringId
                updatedAt = now
                audit.logAudit(user, "QR UPDATED", "QR neu generiert")
            }
        )
    }

    fun getQrCode(entitlement: Entitlement, time: ZonedDateTime = ZonedDateTime.now()): String {
        val causeId = entitlement.entitlementCauseId
        val personId = entitlement.personId
        val entitlementId = entitlement.id
        val epochs = time.toEpochSecond()
        val string = "$causeId-$personId-$entitlementId-$epochs"
        return string
    }

    override fun viewQrPdf(user: OflUser, id: String): FileResult? {
        AdminPermissions.assertPermission(user, UserRole.READER)

        val entitlement = entitlementRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        val person = personRepository.findByIdOrNull(entitlement.personId)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        val campaign = campaignRepository.findByIdOrNull(entitlement.campaignId)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        val entitlementCause = causeRepository.findByIdOrNull(entitlement.entitlementCauseId)
            ?: throw EntitlementsError.NoEntitlementFound(id)

        if (entitlement.code == null) {
            throw EntitlementsError.InvalidEntitlementNoQr(id)
        }
        val qrValue = restConstantsService.getWebBaseUrl() + "/qr/" + entitlement.code
        return pdfGenerator.createPersonEntitlementQrPdf(
            pdfInfo = PdfInfo("${entitlement.id}.pdf"),
            person = person,
            entitlement = entitlement,
            qrValue = qrValue,
            campaignName = campaign.name,
            entitlementName = entitlementCause.name,
        )
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
