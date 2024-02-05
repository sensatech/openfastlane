package at.sensatech.openfastlane.api.testcommons

import at.sensatech.openfastlane.common.ApplicationProfiles
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Profile
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService

/**
 * Use only for Mocking.
 *
 */
@Profile(ApplicationProfiles.TEST)
@TestConfiguration
class TestAdminDetailsService : UserDetailsService {

    override fun loadUserByUsername(username: String?): UserDetails {
        val roles = if (username!!.contains("superuser")) {
            listOf("ROLE_OFL_SUPERUSER")
        } else if (username.contains("admin")) {
            listOf("ROLE_OFL_ADMIN")
        } else if (username.contains("manager")) {
            listOf("ROLE_OFL_MANAGER")
        } else if (username.contains("writer")) {
            listOf("ROLE_OFL_WRITER")
        } else {
            listOf("ROLE_OFL_READER")
        }
        return TestOflUserDetails(
            principal = username,
            credentials = "passwordEncrypted",
            roles = roles.map { SimpleGrantedAuthority(it) }.toMutableList()
        )
    }
}
