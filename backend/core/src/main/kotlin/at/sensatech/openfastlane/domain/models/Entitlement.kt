package at.sensatech.openfastlane.domain.models

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field

@Document(collection = "entitlement")
data class Entitlement(
    @Id
    val id: String,

    @Field("campaign_id")
    val campaignId: String,

    @Field("entitlement_cause_id")
    val entitlementCauseId: String,

    @Field("person_id")
    val personId: String,

    val values: MutableList<EntitlementValue>
)
