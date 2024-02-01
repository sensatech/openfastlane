package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document

@Document
data class EntitlementCriteria(
    val name: String,
    val type: EntitlementCriteriaType,
    val reportKey: String?
)