package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.security.OflUser
import java.time.LocalDate

interface PersonsService {

    fun createPerson(user: OflUser, data: CreatePerson, strictMode: Boolean): Person

    fun updatePerson(user: OflUser, id: String, data: UpdatePerson): Person

    fun getPerson(
        user: OflUser,
        id: String,
        withEntitlements: Boolean
    ): Person?

    fun getPersonSimilars(
        user: OflUser,
        id: String,
        withEntitlements: Boolean
    ): List<Person>

    fun listPersons(
        user: OflUser,
        withEntitlements: Boolean
    ): List<Person>

    fun findSimilarPersons(
        user: OflUser,
        firstName: String,
        lastName: String,
        dateOfBirth: LocalDate?,
        withEntitlements: Boolean
    ): List<Person>

    fun findWithSimilarAddress(
        user: OflUser,
        addressId: String?,
        streetNameNumber: String?,
        addressSuffix: String?,
        withEntitlements: Boolean
    ): List<Person>
}
