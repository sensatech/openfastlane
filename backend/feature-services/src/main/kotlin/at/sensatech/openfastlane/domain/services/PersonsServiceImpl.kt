package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.LocalDate

@Service
class PersonsServiceImpl(
    private val personRepository: PersonRepository
) : PersonsService {

    override fun getPerson(user: OflUser, id: String): Person? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findByIdOrNull(id)
    }

    override fun listPersons(user: OflUser): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findAll().toList()
    }

    override fun findSimilarPersons(
        user: OflUser,
        firstName: String,
        lastName: String,
        birthDay: LocalDate?
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return if (birthDay != null) {
            personRepository.findByFirstNameAndLastNameAndBirthDate(firstName, lastName, birthDay)
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
