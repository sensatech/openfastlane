package at.sensatech.openfastlane.domain.models

data class EntitlementCriteriaOption(
    val key: String,
    val label: String,
    val order: Int = 0,
    val description: String? = null
)
