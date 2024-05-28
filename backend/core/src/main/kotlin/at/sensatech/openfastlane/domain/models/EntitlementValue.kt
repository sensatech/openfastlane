package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport

@ExcludeFromJacocoGeneratedReport
data class EntitlementValue(
    val criteriaId: String,
    val type: EntitlementCriteriaType,
    var value: String
) {
    fun invalid(): Boolean {
        return value.isEmpty() || value.isBlank() || value == "0" || value == "false" || value == "null" || value == "0.0"
    }
}
