package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.models.EntitlementValue

@ExcludeFromJacocoGeneratedReport
data class UpdateEntitlement(
    val values: List<EntitlementValue>
)
