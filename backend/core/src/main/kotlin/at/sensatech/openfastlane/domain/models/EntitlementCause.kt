package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field
import java.util.Objects

@ExcludeFromJacocoGeneratedReport
@Document
class EntitlementCause(
    @Id
    val id: String,

    @Field("campaign_id")
    val campaignId: String,

    var name: String,

    val criterias: MutableList<EntitlementCriteria>
) {
    override fun equals(other: Any?): Boolean {
        return if (other is EntitlementCause) {
            id == other.id
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }
}
