package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.documents.pdf.PdfGenerator
import at.sensatech.openfastlane.documents.pdf.PdfInfo
import at.sensatech.openfastlane.domain.config.RestConstantsService
import at.sensatech.openfastlane.domain.events.EntitlementEvent
import at.sensatech.openfastlane.domain.events.MailEvent
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.models.logAudit
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.mailing.MailError
import at.sensatech.openfastlane.mailing.MailRequests
import at.sensatech.openfastlane.mailing.MailService
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import at.sensatech.openfastlane.tracking.TrackingService
import org.assertj.core.util.VisibleForTesting
import org.slf4j.LoggerFactory
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

@Service
class EntitlementsServiceImpl(
    private val entitlementRepository: EntitlementRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val campaignRepository: CampaignRepository,
    private val personRepository: PersonRepository,
    private val restConstantsService: RestConstantsService,
    private val pdfGenerator: PdfGenerator,
    private val mailService: MailService,
    private val trackingService: TrackingService,
) : EntitlementsService {

    private val dateFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")

    override fun listAllEntitlements(user: OflUser): List<Entitlement> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        trackingService.track(EntitlementEvent.List())
        return entitlementRepository.findAll()
    }

    override fun getEntitlement(user: OflUser, id: String): Entitlement? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        trackingService.track(EntitlementEvent.View())
        return entitlementRepository.findByIdOrNull(id)
    }

    override fun getPersonEntitlements(user: OflUser, personId: String): List<Entitlement> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val person = guardPerson(personId)
        trackingService.track(EntitlementEvent.ViewPersonEntitlements())
        return entitlementRepository.findByPersonId(person.id)
    }

    override fun createEntitlement(user: OflUser, request: CreateEntitlement): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val personId = request.personId
        val entitlementCauseId = request.entitlementCauseId

        val entitlementCause = guardEntitlementCause(entitlementCauseId)
        val person = guardPerson(personId)

        log.info("Creating entitlement for person {} with entitlement cause {}", personId, entitlementCauseId)

        val entitlements = getPersonEntitlements(user, person.id)
        val matchingEntitlements = entitlements.filter { it.entitlementCauseId == entitlementCauseId }
        if (matchingEntitlements.isNotEmpty()) {
            throw EntitlementsError.PersonEntitlementAlreadyExists(matchingEntitlements.first().id)
        }

        val valueSet = entitlementCause.criterias.map { EntitlementValue(it.id, it.type, "") }

        log.info("Creating base values for person {} with valueSet {}", personId, valueSet)
        val finalCreateValues = mergeValues(valueSet, request.values).toMutableList()
        val entitlement = Entitlement(
            id = newId(),
            personId = personId,
            campaignId = entitlementCause.campaignId,
            entitlementCauseId = entitlementCause.id,
            status = EntitlementStatus.PENDING,
            values = finalCreateValues,
        )

        entitlement.audit.logAudit(user, "CREATED", "Angelegt mit ${request.values.size} Werten")
        trackingService.track(EntitlementEvent.Create(entitlementCause.name, length = finalCreateValues.size))
        val saved = entitlementRepository.save(entitlement)
        return saved
    }

    fun mergeValues(baseValues: List<EntitlementValue>, newValues: List<EntitlementValue>): List<EntitlementValue> {
        return baseValues.map { value ->
            val newValue = newValues.find { it.criteriaId == value.criteriaId }
            if (newValue != null) {
                log.debug("Merging value for criteria {} with new value {}", value.criteriaId, newValue.value)
                EntitlementValue(value.criteriaId, value.type, newValue.value)
            } else {
                log.debug("Merging value for criteria {} with empty value", value.criteriaId)
                value
            }
        }
    }

    override fun updateEntitlement(user: OflUser, id: String, request: UpdateEntitlement): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = guardEntitlement(id)
        val entitlementCause = guardEntitlementCause(entitlement.entitlementCauseId)

        val currentBaseValues = entitlementCause.criterias.map {
            EntitlementValue(it.id, it.type, "")
        }

        log.info("Updating entitlement {} with currentBaseValues {}", id, currentBaseValues)
        log.info("Updating entitlement {} with values {}", id, request.values)
        val validCurrentValues = mergeValues(currentBaseValues, entitlement.values)
        val patchedNewValues = mergeValues(validCurrentValues, request.values)
        entitlement.apply {
            updatedAt = ZonedDateTime.now()
            values = patchedNewValues.toMutableList()
        }

        val status = validateEntitlement(entitlement)

        log.info("Updating entitlement {} with status {}, old status was {}", id, status, entitlement.status)
        entitlement.audit.logAudit(
            user,
            "UPDATED",
            "${request.values.size} Werte aktualisiert, alter Status: ${entitlement.status}, neu: $status"
        )
        entitlement.status = status
        val saved = entitlementRepository.save(entitlement)
        trackingService.track(EntitlementEvent.Update(entitlementCause.name, length = request.values.size))
        return saved
    }

    override fun extendEntitlement(user: OflUser, id: String): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = guardEntitlement(id)
        guardCampaign(entitlement.campaignId)

        val expandTime = expandForPeriod(ZonedDateTime.now())
        val oldExpiresAt = dateFormatter.format(entitlement.expiresAt ?: ZonedDateTime.now())
        val oldStatus = entitlement.status
        entitlement.apply {
            expiresAt = expandTime
            confirmedAt = ZonedDateTime.now()
            updatedAt = ZonedDateTime.now()
        }

        log.info("Extending entitlement {} to {}", id, expandTime)
        // call AFTER updating expiresAt
        val status = validateEntitlement(entitlement)
        entitlement.status = status
        entitlement.audit.logAudit(
            user,
            "EXTENDED",
            "Verlängert bis ${dateFormatter.format(expandTime)} (war $oldExpiresAt) mit Status $status (war $oldStatus)"
        )
        trackingService.track(EntitlementEvent.Extend())
        return entitlementRepository.save(entitlement)
    }

    fun validateEntitlement(entitlement: Entitlement): EntitlementStatus {
        val cause = guardEntitlementCause(entitlement.entitlementCauseId)

        if (entitlement.expiresAt == null) {
            log.info("Entitlement {} has no expiration date, status = PENDING", entitlement.id)
            return EntitlementStatus.PENDING
        } else if (entitlement.expiresAt!!.isBefore(ZonedDateTime.now())) {
            log.info("Entitlement {} has past expiration {}, status = EXPIRED", entitlement.id, entitlement.expiresAt)
            return EntitlementStatus.EXPIRED
        }

        val values = entitlement.values

        cause.criterias.forEach { criterion ->
            val currentValue = values.find { it.criteriaId == criterion.id }
            if (currentValue == null || currentValue.invalid()) {
                log.info(
                    "Entitlement {} is missing criteria {}, status = INVALID",
                    entitlement.id,
                    criterion.toString()
                )
                return EntitlementStatus.INVALID
            } else {
                if (!checkCriteria(criterion, currentValue)) {
                    log.info(
                        "Entitlement {} has invalid criteria {}, status = INVALID",
                        entitlement.id,
                        criterion.toString()
                    )
                    return EntitlementStatus.INVALID
                }
            }
        }
        log.info("Entitlement {}  status = INVALID", entitlement.id)
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

    private fun createQrPdfFile(user: OflUser, entitlement: Entitlement, person: Person): FileResult? {
        AdminPermissions.assertPermission(user, UserRole.READER)

        val campaign = guardCampaign(entitlement.campaignId)
        val entitlementCause = guardEntitlementCause(entitlement.entitlementCauseId)

        val entitlementWithQr = ensureUpdatedQrCode(user, entitlement)
        val qrValue = restConstantsService.getWebBaseUrl() + "/qr/" + entitlementWithQr.code

        log.info("Creating QR PDF for entitlement {} code: {}", entitlementWithQr.id, entitlementWithQr.code)
        return pdfGenerator.createPersonEntitlementQrPdf(
            pdfInfo = PdfInfo("${entitlementWithQr.id}.pdf"),
            person = person,
            entitlement = entitlementWithQr,
            qrValue = qrValue,
            campaignName = campaign.name,
            entitlementName = entitlementCause.name,
        )
    }

    override fun viewQrPdf(user: OflUser, id: String): FileResult? {
        AdminPermissions.assertPermission(user, UserRole.READER)

        val entitlement = guardEntitlement(id)
        val person = guardPerson(entitlement.personId)

        val fileResult = createQrPdfFile(user, entitlement, person)
        if (fileResult?.file == null) {
            log.error("viewQrPdf: Could not create QR PDF for entitlement {}", entitlement.id)
            throw EntitlementsError.InvalidEntitlementNoQr(entitlement.id)
        }

        trackingService.track(EntitlementEvent.ViewQrCode())

        return fileResult
    }

    override fun sendQrPdf(user: OflUser, id: String, mailRecipient: String?) {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val entitlement = guardEntitlement(id)
        val person = guardPerson(entitlement.personId)

        val mail = assertUsefulMailAddress(mailRecipient, person.email)

        val fileResult = createQrPdfFile(user, entitlement, person)
        if (fileResult?.file == null) {
            log.error("sendQrPdf: Could not create QR PDF for entitlement {}", entitlement.id)
            throw EntitlementsError.InvalidEntitlementNoQr(entitlement.id)
        }
        
        trackingService.track(EntitlementEvent.SendQrCode())

        try {
            mailService.sendMail(
                MailRequests.sendQrPdf(
                    mail,
                    Locale.GERMAN,
                    person.firstName,
                    person.lastName,
                ),
                attachments = listOf(fileResult.file!!)
            )
            trackingService.track(MailEvent.Success())
            entitlement.audit.logAudit(user, "QR SENT", "QR Mail versendet")
            entitlementRepository.save(entitlement)
        } catch (e: Throwable) {
            trackingService.track(MailEvent.Failure(e.cause?.message ?: e.message ?: "unknown"))
            log.error("Could not send QR PDF for entitlement {}", entitlement.id, e)
            throw e
        }
    }

    private fun assertUsefulMailAddress(mailRecipient: String?, storedMailAddress: String?): String {
        val mail = if (!mailRecipient.isNullOrEmpty()) mailRecipient else storedMailAddress

        if (mail.isNullOrEmpty()) {
            throw MailError.SendingFailedMissingRecipient("person.email and mailRecipient both are null/blank")
        }

        // check for valid mail:
        if (!mail.matches(Regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}\$"))) {
            throw MailError.SendingFailedInvalidRecipient("mailRecipient is not a valid email address: $mail")
        }
        return mail
    }

    @VisibleForTesting
    fun ensureUpdatedQrCode(user: OflUser, entitlement: Entitlement): Entitlement {

        if (entitlement.code != null && entitlement.status == EntitlementStatus.VALID) {
            log.info("VALID Entitlement {} already has a QR code", entitlement.id)
            return entitlement
        }

        val entitlementStatus = validateEntitlement(entitlement)
        if (entitlementStatus != EntitlementStatus.VALID) {
            throw EntitlementsError.InvalidEntitlement(entitlementStatus.toString())
        }

        val now = ZonedDateTime.now()
        val stringId = generateQrCodeString(entitlement, now)

        trackingService.track(EntitlementEvent.UpdateQrCode())

        return entitlementRepository.save(
            entitlement.apply {
                code = stringId
                updatedAt = now
                audit.logAudit(user, "QR UPDATED", "QR neu generiert")
            }
        )
    }

    @VisibleForTesting
    fun generateQrCodeString(entitlement: Entitlement, time: ZonedDateTime = ZonedDateTime.now()): String {
        val causeId = entitlement.entitlementCauseId
        val personId = entitlement.personId
        val entitlementId = entitlement.id
        val epochs = time.toEpochSecond()
        val string = "$causeId-$personId-$entitlementId-$epochs"
        return string
    }

    private fun guardEntitlement(id: String): Entitlement {
        return entitlementRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementFound(id)
    }

    private fun guardEntitlementCause(id: String): EntitlementCause {
        return causeRepository.findByIdOrNull(id)
            ?: throw EntitlementsError.NoEntitlementCauseFound(id)
    }

    private fun guardPerson(personId: String): Person {
        return personRepository.findByIdOrNull(personId)
            ?: throw PersonsError.NotFoundException(personId)
    }

    private fun guardCampaign(id1: String): Campaign {
        return campaignRepository.findByIdOrNull(id1)
            ?: throw EntitlementsError.NoCampaignFound(id1)
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
