package at.sensatech.openfastlane.testcommons

import at.sensatech.openfastlane.mocks.Mocks.mockPerson
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import java.time.LocalDate
import java.util.UUID

open class AbstractMockedServiceTest {
    val superuser = OflUser(UUID.randomUUID().toString(), "superuser", UserRole.SUPERUSER)
    val admin = OflUser(UUID.randomUUID().toString(), "admin", UserRole.ADMIN)
    val manager = OflUser(UUID.randomUUID().toString(), "manager", UserRole.MANAGER)
    val reader = OflUser(UUID.randomUUID().toString(), "reader", UserRole.READER)

    val unknownId = "unknownId"

    val firstPerson = mockPerson()
    val persons = listOf(
        firstPerson,
        mockPerson(
            addressId = firstPerson.address?.addressId!!,
            dateOfBirth = LocalDate.of(1980, 11, 11)
        ), // same name as first
        mockPerson(firstName = "Berta", addressSuffix = "2"),
        mockPerson(firstName = "Charlie", addressSuffix = "3"),
        mockPerson(firstName = "Dori", addressSuffix = "4"),
    )
}