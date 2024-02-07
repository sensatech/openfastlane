package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.security.OflUser
import java.time.LocalDate

interface PersonsService {

    fun createPerson(user: OflUser, data: CreatePerson, strictMode: Boolean): Person

    fun getPerson(user: OflUser, id: String): Person?

    fun getPersonSimilars(user: OflUser, id: String): List<Person>

    fun listPersons(user: OflUser): List<Person>

    fun findSimilarPersons(user: OflUser, firstName: String, lastName: String, dateOfBirth: LocalDate?): List<Person>

    fun findWithSimilarAddress(
        user: OflUser,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?
    ): List<Person>
}
