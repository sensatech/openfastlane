package at.sensatech.openfastlane.api.common

import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority

class OflAuthentication(
    private val principal: Any,
    private val credentials: Any,
    override val roles: MutableCollection<out GrantedAuthority>,
) : AbstractAuthenticationToken(roles), OflUserDetails {

    override fun getCredentials(): Any {
        return credentials
    }

    override fun getPrincipal(): Any {
        return principal
    }

    override val id: String
        get() = principal as String

    override fun getUsername(): String = principal as String
}
