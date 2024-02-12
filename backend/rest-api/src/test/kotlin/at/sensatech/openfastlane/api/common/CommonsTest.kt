package at.sensatech.openfastlane.api.common

import at.sensatech.openfastlane.security.UserRole
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt

class CommonsTest {
    @Test
    fun `OflAuthentication should return principal as getUsername`() {

        val subject = OflAuthentication(
            "principal",
            "credentials",
            mutableListOf()
        )

        assertThat(subject.getUsername()).isEqualTo("principal")
        assertThat(subject.principal).isEqualTo("principal")
        assertThat(subject.id).isEqualTo("principal")
        assertThat(subject.credentials).isEqualTo("credentials")
    }

    @Test
    fun `OflAuthentication should return grantedAuthority`() {

        val grantedAuthority = SimpleGrantedAuthority("role")
        val subject = OflAuthentication(
            "principal",
            "credentials",
            mutableListOf(grantedAuthority)
        )

        assertThat(subject.roles).containsExactly(grantedAuthority)
    }

    @Test
    fun `OflAuthentication toUser should return OflUser`() {

        val grantedAuthority = SimpleGrantedAuthority("ROLE_OFL_MANAGER")
        val subject = OflAuthentication(
            "principal",
            "credentials",
            mutableListOf(grantedAuthority)
        )

        val result = subject.toUser()

        assertThat(result).isNotNull
    }

    @Nested
    inner class userRole {

        private val rolesWithPrefix = arrayListOf(
            SimpleGrantedAuthority("ROLE_OFL_SUPERUSER"),
            SimpleGrantedAuthority("ROLE_OFL_ADMIN"),
            SimpleGrantedAuthority("ROLE_OFL_MANAGER"),
            SimpleGrantedAuthority("ROLE_OFL_READER"),
        )
        private val rolesWithoutPrefix = arrayListOf(
            SimpleGrantedAuthority("OFL_SUPERUSER"),
            SimpleGrantedAuthority("OFL_ADMIN"),
            SimpleGrantedAuthority("OFL_MANAGER"),
            SimpleGrantedAuthority("OFL_READER"),
        )

        @Test
        fun `OflAuthentication toUser should map Roles with prefix`() {

            val subject = OflAuthentication(
                "principal",
                "credentials",
                rolesWithPrefix
            )

            val result = subject.toUser()

            assertThat(result).isNotNull
            assertThat(result!!.userRole).isEqualTo(UserRole.SUPERUSER)
        }

        @Test
        fun `OflAuthentication toUser should map Roles without prefix`() {

            val subject = OflAuthentication(
                "principal",
                "credentials",
                rolesWithoutPrefix
            )

            val result = subject.toUser()

            assertThat(result).isNotNull
            assertThat(result!!.userRole).isEqualTo(UserRole.SUPERUSER)
        }
    }

    @Nested
    inner class `Jwt toUser` {

        @Test
        fun `toUser should need preferred_username`() {
            val test = Jwt(
                "tokenValue",
                null,
                null,
                mapOf("bla" to "value"),
                mutableMapOf(
                    "bla" to "username",
                    "realm_access" to mapOf(
                        "roles" to listOf("ROLE_OFL_SUPERUSER")
                    )
                )

            )
            assertThrows<IllegalArgumentException> {
                test.toUser()
            }
        }

        @Test
        fun `toUser should need user_role`() {
            val test = Jwt(
                "tokenValue",
                null,
                null,
                mapOf("bla" to "value"),
                mutableMapOf(
                    "preferred_username" to "username",
                    "realm_access" to mapOf(
                        "bla" to listOf("ROLE_OFL_SUPERUSER")
                    )
                )

            )
            assertThrows<NullPointerException> {
                test.toUser()
            }
        }

        @Test
        fun `toUser should translate everything properly`() {
            val test = Jwt(
                "tokenValue",
                null,
                null,
                mapOf("bla" to "value"),
                mutableMapOf(
                    "jti" to "jti",
                    "preferred_username" to "username",
                    "realm_access" to mapOf(
                        "roles" to listOf("OFL_SUPERUSER")
                    )
                )

            )
            val result = test.toUser()
            assertThat(result).isNotNull
            assertThat(result!!.id).isNotNull
            assertThat(result.id).isEqualTo("jti")
            assertThat(result.username).isNotNull
            assertThat(result.username).isEqualTo("username")
            assertThat(result.userRole).isNotNull
            assertThat(result.userRole).isEqualTo(UserRole.SUPERUSER)
        }
    }
}
