package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Entitlement
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
        val entitlements = getPersonEntitlements(user, personId)
        val matchingEntitlements = entitlements.filter { it.entitlementCauseId == request.entitlementCauseId }
        if (matchingEntitlements.isNotEmpty()) {
            throw IllegalArgumentException("Entitlement already exists")
        }

        val entitlement = Entitlement(
            id = newId(),
            personId = personId,
            entitlementCauseId = request.entitlementCauseId,
            values = request.values.toMutableList(),
        )
        val saved = entitlementRepository.save(entitlement)
        return saved
    }
}
