package at.sensatech.openfastlane.mocks

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Person
import java.time.LocalDate
import java.time.ZonedDateTime

object Mocks {

    fun mockPerson(
        id: String = newId(),
        firstName: String = "John",
        lastName: String = "Doe",
        birthDate: LocalDate? = LocalDate.of(1980, 10, 10),
        addressSuffix: String = "1",
        email: String = "mail@example.com",
        mobileNumber: String = "+43 123 456 789",
    ): Person {
        return Person(
            id = id,
            firstName = firstName,
            lastName = lastName,
            gender = Gender.DIVERSE,
            birthDate = birthDate,
            address = Address(
                streetNameNumber = "Main Street 1",
                addressSuffix = addressSuffix,
                postalCode = "1234",
            ),
            email = email,
            mobileNumber = mobileNumber,
            comment = "",
            createdAt = ZonedDateTime.now(),
            updatedAt = ZonedDateTime.now(),
        )
    }
}