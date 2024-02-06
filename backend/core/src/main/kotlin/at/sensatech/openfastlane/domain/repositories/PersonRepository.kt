package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Person
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import java.time.LocalDate

@Repository
interface PersonRepository : MongoRepository<Person, String> {
    fun findByFirstNameAndLastName(firstName: String, lastName: String): List<Person>
    fun findByFirstNameAndLastNameAndDateOfBirth(
        firstName: String,
        lastName: String,
        dateOfBirth: LocalDate
    ): List<Person>
    fun findByAddressAddressId(addressId: String): List<Person>
    fun findByAddressAddressIdAndAddressAddressSuffix(addressId: String, addressSuffix: String): List<Person>

    fun findByAddressStreetNameNumber(streetNameNumber: String): List<Person>
    fun findByAddressStreetNameNumberAndAddressAddressSuffix(
        streetNameNumber: String,
        addressSuffix: String
    ): List<Person>
}
