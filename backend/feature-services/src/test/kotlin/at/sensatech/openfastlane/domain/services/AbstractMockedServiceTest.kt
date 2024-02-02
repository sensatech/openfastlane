package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.mocks.Mocks.mockPerson
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import java.util.*

open class AbstractMockedServiceTest {
    val superuser = OflUser(UUID.randomUUID().toString(), "superuser", UserRole.SUPERUSER)
    val admin = OflUser(UUID.randomUUID().toString(), "admin", UserRole.ADMIN)
    val manager = OflUser(UUID.randomUUID().toString(), "manager", UserRole.MANAGER)
    val reader = OflUser(UUID.randomUUID().toString(), "reader", UserRole.READER)

    val unknownId = "unknownId"

    val firstPerson = mockPerson()
    val persons = listOf(
        firstPerson,
        mockPerson(),
        mockPerson(),
        mockPerson(),
    )
}
