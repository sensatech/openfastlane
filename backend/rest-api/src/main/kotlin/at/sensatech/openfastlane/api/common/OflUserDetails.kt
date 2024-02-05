package at.sensatech.openfastlane.api.common

import at.sensatech.openfastlane.security.UserRole
import org.springframework.security.core.GrantedAuthority

/**
 * Needed to support both Keycloak JWT Authentication and
 * Mocked Authentication via UserDetails in Spring boot.
 */
interface OflUserDetails {
    val id: String
    val roles: MutableCollection<out GrantedAuthority>

    fun getUserRole(): UserRole? {
        return UserRole.entries.firstOrNull { level ->
            roles.any { it.authority.removePrefix("ROLE_") == level.role }
        }
    }

    fun getUsername(): String
}
