package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.common.toLocalDateOrNull
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.models.logAudit
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.slf4j.LoggerFactory
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.ZonedDateTime

@Service
class PersonsServiceImpl(
    private val personRepository: PersonRepository,
    private val entitlementRepository: EntitlementRepository
) : PersonsService {

    override fun createPerson(user: OflUser, data: CreatePerson, strictMode: Boolean): Person {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        log.info("Creating person with data: ${data.firstName} ${data.dateOfBirth} ")
        val localDate = data.dateOfBirth?.toLocalDateOrNull()
        val similarPersons = similarPersons(user, data.firstName, data.lastName, localDate, data.address)
        val objectIds = similarPersons.map { it.id }.toSortedSet()
        if (strictMode && objectIds.isNotEmpty()) {
            log.warn("StrictModeDuplicatesCreation: ${objectIds.size}")
            throw PersonsError.StrictModeDuplicatesCreation(objectIds.size)
        }

        val person = Person(
            id = newId(),
            firstName = data.firstName,
            lastName = data.lastName,
            dateOfBirth = data.dateOfBirth?.toLocalDateOrNull(),
            address = data.address,
            email = data.email,
            mobileNumber = data.mobileNumber,
            gender = data.gender,
            createdAt = ZonedDateTime.now(),
            similarPersonIds = objectIds
        )
        person.audit.logAudit(user, "CREATED", "Person angelegt: ${person.summary()} ")
        val save = personRepository.save(person)

        updateLinkedPerson(save, similarPersons, setOf())
        return save
    }

    override fun updatePerson(
        user: OflUser,
        id: String,
        data: UpdatePerson,
        withEntitlements: Boolean
    ): Person {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val existing = personRepository.findByIdOrNull(id)
            ?: throw PersonsError.NotFoundException(id)

        val oldSimilarPersons = existing.similarPersonIds

        existing.apply {
            firstName = data.firstName ?: this.firstName
            lastName = data.lastName ?: this.lastName
            dateOfBirth = data.dateOfBirth?.toLocalDateOrNull() ?: this.dateOfBirth
            address = data.address ?: this.address
            email = data.email ?: this.email
            mobileNumber = data.mobileNumber ?: this.mobileNumber
            updatedAt = ZonedDateTime.now()
        }

        val similarPersons =
            similarPersons(user, existing.firstName, existing.lastName, existing.dateOfBirth, existing.address)
        val objectIds = similarPersons.map { it.id }.toSortedSet()
        existing.similarPersonIds = objectIds
        existing.audit.logAudit(user, "UPDATED", "Alte Personendaten: ${existing.summary()}")

        val updated = personRepository.save(existing)
        updateLinkedPerson(updated, similarPersons, oldSimilarPersons)

        val personEntitlements = if (withEntitlements) {
            entitlementRepository.findByPersonId(updated.id)
        } else null
        return updated.attachEntitlements(personEntitlements)
    }

    private fun updateLinkedPerson(person: Person, similarPersons: List<Person>, oldSimilarPersonIds: Set<String>) {
        log.info("Save person with: ${person.firstName} similarPersonIds: ${similarPersons.size} -> $similarPersons")

        similarPersons.forEach {
            if (!oldSimilarPersonIds.contains(it.id)) {

                val linkedPerson = person.id
                val toSortedSet = (it.similarPersonIds + linkedPerson).toSortedSet()
                it.similarPersonIds = toSortedSet
                log.info("Update a linked Similar person: ${it.id} linkedPerson: add $linkedPerson to ${toSortedSet.size}")
                personRepository.save(it)
            } else {
                log.debug("Already included in similarPersons: ${it.id} linkedPerson: ${person.id}")
            }
        }
    }

    private fun similarPersons(
        user: OflUser,
        firstName: String?,
        lastName: String?,
        localDate: LocalDate?,
        address: Address?,
        withEntitlements: Boolean = false,
    ): List<Person> {

        val findSimilarNamePersons = if (firstName != null && lastName != null) {
            this.findSimilarPersons(user, firstName, lastName, localDate, withEntitlements = withEntitlements)
        } else {
            emptyList()
        }

        val similarAddressPersons = if (address != null) {
            this.findWithSimilarAddress(
                user,
                address.addressId,
                address.streetNameNumber,
                address.addressSuffix,
                withEntitlements = withEntitlements
            )
        } else {
            emptyList()
        }
        val similarPersons = (findSimilarNamePersons + similarAddressPersons)
        return similarPersons
    }

    override fun getPerson(user: OflUser, id: String, withEntitlements: Boolean): Person? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val person = personRepository.findByIdOrNull(id) ?: return null
        val personEntitlements = if (withEntitlements) {
            entitlementRepository.findByPersonId(person.id)
        } else null
        return person.attachEntitlements(personEntitlements)
    }

    override fun getPersonSimilars(user: OflUser, id: String, withEntitlements: Boolean): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val findByIdOrNull = personRepository.findByIdOrNull(id) ?: return emptyList()
        val ids = findByIdOrNull.similarPersonIds
        val entitlements = mayLoadEntitlements(withEntitlements)
        return personRepository.findAllById(ids).toList().mapNotNull { it.attachEntitlements(entitlements) }
    }

    override fun listPersons(user: OflUser, withEntitlements: Boolean): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val entitlements = mayLoadEntitlements(withEntitlements)
        return personRepository.findAll().toList().mapNotNull { it.attachEntitlements(entitlements) }
    }

    override fun findSimilarPersons(
        user: OflUser,
        firstName: String,
        lastName: String,
        dateOfBirth: LocalDate?,
        withEntitlements: Boolean
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val entitlements = mayLoadEntitlements(withEntitlements)
        return if (dateOfBirth != null) {
            personRepository.findByFirstNameContainingIgnoreCaseAndLastNameContainingIgnoreCaseAndDateOfBirth(firstName, lastName, dateOfBirth)
                .mapNotNull { it.attachEntitlements(entitlements) }
        } else {
            personRepository.findByFirstNameContainingIgnoreCaseAndLastNameContainingIgnoreCase(firstName, lastName)
                .mapNotNull { it.attachEntitlements(entitlements) }
        }
    }

    override fun findWithSimilarAddress(
        user: OflUser,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?,
        withEntitlements: Boolean
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val persons = if (addressId != null) {
            if (addressSuffix == null) {
                personRepository.findByAddressAddressId(addressId)
            } else {
                personRepository.findByAddressAddressIdAndAddressAddressSuffix(addressId, addressSuffix)
            }
        } else if (streetNameNumber != null) {
            if (addressSuffix == null) {
                personRepository.findByAddressStreetNameNumberContainingIgnoreCase(streetNameNumber)
            } else {
                personRepository.findByAddressStreetNameNumberContainingIgnoreCaseAndAddressAddressSuffix(
                    streetNameNumber,
                    addressSuffix
                )
            }
        } else {
            return emptyList()
        }
        val entitlements = mayLoadEntitlements(withEntitlements)
        return persons.map { it.attachEntitlements(entitlements) }
    }

    override fun find(
        user: OflUser,
        firstName: String?,
        lastName: String?,
        dateOfBirth: LocalDate?,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?,
        withEntitlements: Boolean
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val findSimilarPersons = if (firstName != null && lastName != null) {
            findSimilarPersons(user, firstName, lastName, dateOfBirth, withEntitlements = withEntitlements)
        } else emptyList()

        val findWithSimilarAddress = if (addressId != null || streetNameNumber != null) {
            findWithSimilarAddress(
                user,
                addressId,
                streetNameNumber,
                addressSuffix,
                withEntitlements = withEntitlements
            )
        } else null

        if (findWithSimilarAddress == null) {
            return findSimilarPersons
        } else {
            val persons = (findSimilarPersons.intersect(findWithSimilarAddress.toSet())).toList()
            return persons
        }
    }

    fun mayLoadEntitlements(withEntitlements: Boolean): List<Entitlement>? {
        if (!withEntitlements) {
            return null
        }
        return entitlementRepository.findAll()
    }

    fun Person.attachEntitlements(entitlements: List<Entitlement>?): Person {
        if (entitlements == null) {
            return this
        }
        val personEntitlements = entitlements.filter { it.personId == this.id }
        return this.apply { this.entitlements = personEntitlements }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
