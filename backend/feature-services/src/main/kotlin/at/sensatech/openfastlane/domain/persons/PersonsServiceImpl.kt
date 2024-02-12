package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.common.toLocalDateOrNull
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.LocalDate
import java.time.ZonedDateTime

@Service
class PersonsServiceImpl(
    private val personRepository: PersonRepository
) : PersonsService {

    override fun createPerson(user: OflUser, data: CreatePerson, strictMode: Boolean): Person {
        AdminPermissions.assertPermission(user, UserRole.MANAGER)

        val localDate = data.dateOfBirth?.toLocalDateOrNull()
        val findSimilarNamePersons = this.findSimilarPersons(user, data.firstName, data.lastName, localDate)
        val similarAddressPersons = if (data.address != null) {
            this.findWithSimilarAddress(
                user,
                data.address?.addressId,
                data.address?.streetNameNumber,
                data.address?.addressSuffix
            )
        } else {
            emptyList()
        }
        val similarPersons = (findSimilarNamePersons + similarAddressPersons)
        val objectIds = similarPersons.map { it.id }.toSortedSet()
        if (strictMode && objectIds.isNotEmpty()) {
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
        val save = personRepository.save(person)

        similarPersons.forEach {
            it.similarPersonIds = (it.similarPersonIds + save.id).toSortedSet()
            personRepository.save(it)
        }
        return save
    }

    override fun getPerson(user: OflUser, id: String): Person? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findByIdOrNull(id)
    }

    override fun getPersonSimilars(user: OflUser, id: String): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        val findByIdOrNull = personRepository.findByIdOrNull(id) ?: return emptyList()
        val ids = findByIdOrNull.similarPersonIds
        return personRepository.findAllById(ids).toList()
    }

    override fun listPersons(user: OflUser): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findAll().toList()
    }

    override fun findSimilarPersons(
        user: OflUser,
        firstName: String,
        lastName: String,
        dateOfBirth: LocalDate?
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return if (dateOfBirth != null) {
            personRepository.findByFirstNameAndLastNameAndDateOfBirth(firstName, lastName, dateOfBirth)
        } else {
            personRepository.findByFirstNameAndLastName(firstName, lastName)
        }
    }

    override fun findWithSimilarAddress(
        user: OflUser,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return if (addressId != null) {
            if (addressSuffix == null) {
                personRepository.findByAddressAddressId(addressId)
            } else {
                personRepository.findByAddressAddressIdAndAddressAddressSuffix(addressId, addressSuffix)
            }
        } else if (streetNameNumber != null) {
            if (addressSuffix == null) {
                personRepository.findByAddressStreetNameNumber(streetNameNumber)
            } else {
                personRepository.findByAddressStreetNameNumberAndAddressAddressSuffix(
                    streetNameNumber,
                    addressSuffix
                )
            }
        } else {
            return emptyList()
        }
    }
}
