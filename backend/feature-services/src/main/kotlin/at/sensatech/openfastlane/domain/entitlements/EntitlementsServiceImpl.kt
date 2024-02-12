package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service

@Service
class EntitlementsServiceImpl(
    private val entitlementRepository: EntitlementRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val personRepository: PersonRepository
) : EntitlementsService {
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
            ?: throw IllegalArgumentException("Person not found")

        return entitlementRepository.findByPersonId(person.id)
    }

    override fun createEntitlement(user: OflUser, request: CreateEntitlement): Entitlement {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val personId = request.personId
        val entitlementCauseId = request.entitlementCauseId

        val entitlementCause = causeRepository.findByIdOrNull(entitlementCauseId)
            ?: throw EntitlementsError.NoEntitlementCauseFound(entitlementCauseId)

        val entitlements = getPersonEntitlements(user, personId)
        val matchingEntitlements = entitlements.filter { it.entitlementCauseId == entitlementCauseId }
        if (matchingEntitlements.isNotEmpty()) {
            throw EntitlementsError.PersonEntitlementAlreadyExists(matchingEntitlements.first().id)
        }

        val entitlement = Entitlement(
            id = newId(),
            personId = personId,
            campaignId = entitlementCause.campaignId,
            entitlementCauseId = entitlementCause.id,
            values = request.values.toMutableList(),
        )
        val saved = entitlementRepository.save(entitlement)
        return saved
    }

    override fun listAllEntitlementCauses(user: OflUser): List<EntitlementCause> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return causeRepository.findAll()
    }

    override fun getEntitlementCause(user: OflUser, id: String): EntitlementCause? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return causeRepository.findByIdOrNull(id)
    }
}
