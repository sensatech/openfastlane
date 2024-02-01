package at.sensatech.openfastlane.security


data class OflUser(
    val id: String,
    val username: String,
    val userRole: UserRole = UserRole.READER,
)
