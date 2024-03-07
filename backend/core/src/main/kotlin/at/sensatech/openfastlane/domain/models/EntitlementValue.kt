package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport

@ExcludeFromJacocoGeneratedReport
data class EntitlementValue(
    val criteriaId: String,
    val type: EntitlementCriteriaType,
    var value: String
)
