package at.sensatech.openfastlane.domain.models

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document
data class EntitlementCause(
    @Id
    val id: String,
    val campaignId: String,
    val name: String,
    val criterias: List<EntitlementCriteria>
)