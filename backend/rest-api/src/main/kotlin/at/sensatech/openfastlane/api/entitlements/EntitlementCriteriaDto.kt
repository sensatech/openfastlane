package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType

class EntitlementCriteriaDto(
    val id: String,
    val name: String,
    val type: EntitlementCriteriaType,
)

internal fun EntitlementCriteria.toDto() = EntitlementCriteriaDto(
    id = this.id,
    name = this.name,
    type = this.type,
)
