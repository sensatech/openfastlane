package at.sensatech.openfastlane.domain.models

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field

@Document
data class EntitlementCause(
    @Id
    val id: String,

    @Field("campaign_id")
    val campaignId: String,

    val name: String,

    val criterias: MutableList<EntitlementCriteria>
)
