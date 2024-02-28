package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
sealed class EntitlementsError(errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class NoEntitlementCauseFound(causeId: String) :
        EntitlementsError(
            "NO_ENTITLEMENT_CAUSE_FOUND",
            "Not EntitlementCause found for id $causeId",
        )

    @ResponseStatus(code = HttpStatus.CONFLICT)
    class PersonEntitlementAlreadyExists(type: String) :
        EntitlementsError(
            "PERSON_ENTITLEMENT_ALREADY_EXISTS",
            "Not EntitlementCause found for id $type",
        )
}
