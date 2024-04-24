package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaOption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType

data class EntitlementCriteriaDto(
    val id: String,
    val name: String,
    val type: EntitlementCriteriaType,
    val options: MutableList<EntitlementCriteriaOption>? = null
)

internal fun EntitlementCriteria.toDto() = EntitlementCriteriaDto(
    id = this.id,
    name = this.name,
    type = this.type,
    options = this.options,
)
