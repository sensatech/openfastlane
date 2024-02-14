package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue

data class EntitlementValueDto(
    val criteriaId: String,
    val type: EntitlementCriteriaType,
    val value: String
)

internal fun EntitlementValue.toDto() = EntitlementValueDto(
    criteriaId = this.criteriaId,
    type = this.type,
    value = this.value.toString()
)
