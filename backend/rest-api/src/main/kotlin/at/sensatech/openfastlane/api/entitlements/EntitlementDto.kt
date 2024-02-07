package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementValue

data class EntitlementDto(
    val id: String,
    val entitlementCauseId: String,
    val personId: String,
    val values: List<EntitlementValueDto>
)

internal fun Entitlement.toDto(): EntitlementDto = EntitlementDto(
    id = this.id,
    entitlementCauseId = this.entitlementCauseId,
    personId = this.personId,
    values = this.values.map(EntitlementValue::toDto)
)
