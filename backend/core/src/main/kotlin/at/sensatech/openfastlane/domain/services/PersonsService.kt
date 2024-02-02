package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.security.OflUser
import java.time.LocalDate

interface PersonsService {

    fun getPerson(user: OflUser, id: String): Person?

    fun listPersons(user: OflUser): List<Person>

    fun findNameDuplicates(user: OflUser, firstName: String, lastName: String, birthDay: LocalDate?): List<Person>

    fun findAddressDuplicates(user: OflUser, addressId: String, addressSuffix: String?): List<Person>

}
