package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.security.OflUser
import java.util.*

interface PersonsService {

    fun getPerson(user: OflUser, id: String): Person?

    fun listPersons(user: OflUser): List<Person>

    fun findNameDuplicates(user: OflUser, firstName: String, lastName: String, birthDay: Date): List<Person>

    fun findAddressDuplicates(user: OflUser, address: Address, addressSuffix: String?): List<Person>

}