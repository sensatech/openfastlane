package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.slf4j.LoggerFactory

internal object AdminPermissions {

    fun assertPermission(
        user: OflUser,
        privilege: UserRole,
    ) {
        checkPermission(user, privilege)?.let { throw it }
    }

    fun checkPermission(
        user: OflUser,
        privilege: UserRole,
    ): UserError? {
        if (user.userRole.isAtLeast(privilege)) {
            if (user.userRole.isAtLeast(UserRole.SUPERUSER)) {
                log.debug("SUPERUSER access: $user")
                return null
            }
            if (user.userRole.isAtLeast(UserRole.ADMIN)) {
                log.debug("ADMIN access: $user for Organisation ")
                return null
            }
        } else {
            log.warn("AdminUser $user tried to invoke a function which needs $privilege")
            return UserError.InsufficientRights(privilege)
        }
        return null
    }

    private val log = LoggerFactory.getLogger(this::class.java)
}
