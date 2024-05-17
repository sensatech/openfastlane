package at.sensatech.openfastlane.testcommons

import at.sensatech.openfastlane.mocks.Mocks
import at.sensatech.openfastlane.mocks.Mocks.mockPerson
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import java.time.LocalDate
import java.util.UUID

open class AbstractMockedServiceTest {
    val superuser = OflUser(UUID.randomUUID().toString(), "superuser", UserRole.SUPERUSER)
    val admin = OflUser(UUID.randomUUID().toString(), "admin", UserRole.ADMIN)
    val manager = OflUser(UUID.randomUUID().toString(), "manager", UserRole.MANAGER)
    val scanner = OflUser(UUID.randomUUID().toString(), "scanner", UserRole.SCANNER)
    val reader = OflUser(UUID.randomUUID().toString(), "reader", UserRole.READER)

    val unknownId = "unknownId"

    val firstPerson = mockPerson(firstName = "FirstPerson").apply {
        entitlements = listOf(
            Mocks.mockEntitlement(this.id),
        )
    }
    val duplicatePerson = mockPerson(
        firstName = "FirstPerson",
        addressId = firstPerson.address?.addressId!!,
        dateOfBirth = LocalDate.of(1980, 11, 11)
    )
    val persons = listOf(
        firstPerson,
        duplicatePerson, // same name as first
        mockPerson(firstName = "Berta", addressSuffix = "2"),
        mockPerson(firstName = "Charlie", addressSuffix = "3"),
        mockPerson(firstName = "Dori", addressSuffix = "4"),
    )
}
