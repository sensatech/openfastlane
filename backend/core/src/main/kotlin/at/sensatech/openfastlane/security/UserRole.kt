package at.sensatech.openfastlane.security

enum class UserRole(private val level: Int, val role: String) {
    SUPERUSER(10, "OFL_SUPERUSER"),
    ADMIN(8, "OFL_ADMIN"),
    MANAGER(6, "OFL_MANAGER"),
    READER(3, "OFL_READER");

    fun isAtLeast(type: UserRole): Boolean {
        return this.level >= type.level
    }

    companion object {
        fun fromRole(role: String): UserRole {
            return entries.single { it.role == role.uppercase() }
        }
    }
}
