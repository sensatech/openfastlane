package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field
import java.util.Objects

@ExcludeFromJacocoGeneratedReport
@Document(collection = "entitlement")
class Entitlement(
    @Id
    val id: String,

    @Field("campaign_id")
    val campaignId: String,

    @Field("entitlement_cause_id")
    val entitlementCauseId: String,

    @Field("person_id")
    val personId: String,

    val values: MutableList<EntitlementValue>
) {
    override fun equals(other: Any?): Boolean {
        return if (other is Entitlement) {
            id == other.id
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }
}
