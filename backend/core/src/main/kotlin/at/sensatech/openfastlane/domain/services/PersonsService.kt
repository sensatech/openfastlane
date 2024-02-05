package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.security.OflUser
import java.time.LocalDate

interface PersonsService {

    fun getPerson(user: OflUser, id: String): Person?

    fun listPersons(user: OflUser): List<Person>

    fun findSimilarPersons(user: OflUser, firstName: String, lastName: String, birthDay: LocalDate?): List<Person>

    fun findWithSimilarAddress(
        user: OflUser,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?
    ): List<Person>

}
