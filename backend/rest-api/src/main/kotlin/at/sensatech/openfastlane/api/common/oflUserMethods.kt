package at.sensatech.openfastlane.api.common

import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.security.oauth2.jwt.Jwt

fun OflUserDetails.requireAdminUser(): OflUser {
    return this.toUser() ?: throw IllegalStateException("User is not an AdminUser")
}

fun OflUserDetails.toUser(): OflUser? {

    val userRole = this.getUserRole() ?: return null
    if (userRole.isAtLeast(UserRole.READER)) {
        return OflUser(
            id = this.id,
            username = this.getUsername(),
            userRole = userRole,
        )
    }
    return null
}

fun Jwt.toUser(): OflUser? {

    val username =
        claims["preferred_username"] as String?
            ?: throw IllegalArgumentException("preferred_username is needed in JWT")

    val realmAccess = claims["realm_access"] as Map<String, Any>
    val roles = (realmAccess["roles"] as List<String>).map {
        it.uppercase()
    }

    val userRole = UserRole.entries.firstOrNull { roles.contains(it.role) }
        ?: throw IllegalArgumentException("user_role is needed in JWT")
    if (userRole.isAtLeast(UserRole.READER)) {
        return OflUser(
            id = this.id,
            username = username,
            userRole = userRole,
        )
    }
    return null
}
