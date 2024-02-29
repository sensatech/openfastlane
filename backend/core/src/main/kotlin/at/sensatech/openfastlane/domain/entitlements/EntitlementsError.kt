package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
sealed class EntitlementsError(errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.NOT_FOUND)
    class NoEntitlementFound(id: String) :
        EntitlementsError(
            "NO_ENTITLEMENT_FOUND",
            "Not Entitlement found for id $id",
        )

    @ResponseStatus(code = HttpStatus.NOT_FOUND)
    class NoEntitlementCauseFound(causeId: String) :
        EntitlementsError(
            "NO_ENTITLEMENT_CAUSE_FOUND",
            "Not EntitlementCause found for id $causeId",
        )

    @ResponseStatus(code = HttpStatus.NOT_FOUND)
    class NoCampaignFound(id: String) :
        EntitlementsError(
            "NO_CAMPAIGN_FOUND",
            "Not Campaign found for id $id",
        )

    @ResponseStatus(code = HttpStatus.CONFLICT)
    class PersonEntitlementAlreadyExists(type: String) :
        EntitlementsError(
            "PERSON_ENTITLEMENT_ALREADY_EXISTS",
            "There is already an Entitlement for that Cause: $type",
        )
}
