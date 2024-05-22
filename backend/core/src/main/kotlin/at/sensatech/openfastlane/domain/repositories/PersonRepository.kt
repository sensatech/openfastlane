package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Person
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import java.time.LocalDate

@Repository
interface PersonRepository : MongoRepository<Person, String> {
    fun findByFirstNameContainingIgnoreCaseAndLastNameContainingIgnoreCase(
        firstName: String,
        lastName: String
    ): List<Person>

    fun findByFirstNameContainingIgnoreCaseAndLastNameContainingIgnoreCaseAndDateOfBirth(
        firstName: String,
        lastName: String,
        dateOfBirth: LocalDate
    ): List<Person>
    fun findByAddressAddressId(addressId: String): List<Person>
    fun findByAddressAddressIdAndAddressAddressSuffix(addressId: String, addressSuffix: String): List<Person>

    fun findByAddressStreetNameNumberContainingIgnoreCase(streetNameNumber: String): List<Person>
    fun findByAddressStreetNameNumberContainingIgnoreCaseAndAddressAddressSuffix(
        streetNameNumber: String,
        addressSuffix: String
    ): List<Person>
}
