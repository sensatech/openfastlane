package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.models.EntitlementValue

@ExcludeFromJacocoGeneratedReport
data class CreateEntitlement(
    val personId: String,
    val entitlementCauseId: String,
    val values: List<EntitlementValue>
)
