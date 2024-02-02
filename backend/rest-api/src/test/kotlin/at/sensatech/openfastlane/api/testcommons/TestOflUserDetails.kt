package at.sensatech.openfastlane.api.testcommons

import at.sensatech.openfastlane.api.common.OflUserDetails
import org.assertj.core.util.VisibleForTesting
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

@VisibleForTesting
data class TestOflUserDetails(
    val principal: String,
    val credentials: String,
    override val roles: MutableCollection<out GrantedAuthority> = arrayListOf(),
) : UserDetails, OflUserDetails {

    override fun getAuthorities(): MutableCollection<out GrantedAuthority> = roles

    override fun getPassword(): String = credentials

    override fun getUsername(): String = principal

    override fun isAccountNonExpired(): Boolean = true

    override fun isAccountNonLocked(): Boolean = true

    override fun isCredentialsNonExpired(): Boolean = false

    override fun isEnabled(): Boolean = true
    override val id: String
        get() = principal

}
