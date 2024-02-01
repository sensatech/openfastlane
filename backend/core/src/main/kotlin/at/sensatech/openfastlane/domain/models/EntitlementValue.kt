package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document

@Document
data class EntitlementValue(
    val criteriaId: String,
    val type: EntitlementCriteriaType,
    val value: Any
)