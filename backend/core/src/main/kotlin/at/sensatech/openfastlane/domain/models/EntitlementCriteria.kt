package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.newId
import org.springframework.data.mongodb.core.mapping.Document

@Document
data class EntitlementCriteria(
    val id: String = newId(),
    val name: String,
    val type: EntitlementCriteriaType,
    val reportKey: String?
)
