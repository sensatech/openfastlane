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

    override fun findNameDuplicates(
        user: OflUser,
        firstName: String,
        lastName: String,
        birthDay: LocalDate?
    ): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findAll().toList()
    }

    override fun findAddressDuplicates(user: OflUser, addressId: String, addressSuffix: String?): List<Person> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return personRepository.findAll().toList()
    }
}
