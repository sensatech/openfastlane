package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.security.UserRole
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

sealed class UserError(errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.FORBIDDEN)
    class InsufficientRights(type: UserRole) :
        UserError(
            "USER_LEVEL_INSUFFICIENT",
            "AdminUser needs more rights for that request, at least $type",
        )

    @ResponseStatus(code = HttpStatus.FORBIDDEN)
    class OrganisationForbidden(orgId: Int) :
        UserError(
            "ORGANISATION_NOT_ALLOWED",
            "AdminUser needs more rights to access Organisation $orgId",
        )

    @ResponseStatus(code = HttpStatus.FORBIDDEN)
    class DepartmentForbidden(depId: Int) :
        UserError(
            "DEPARTMENT_NOT_ALLOWED",
            "AdminUser needs more rights to access DEPARTMENT $depId",
        )
}
