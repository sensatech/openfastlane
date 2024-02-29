package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.common.newId
import org.springframework.data.mongodb.core.mapping.Document
import java.util.Objects

@ExcludeFromJacocoGeneratedReport
@Document
class EntitlementCriteria(
    val id: String = newId(),
    var name: String,
    var type: EntitlementCriteriaType,
    var reportKey: String? = null,
    val options: MutableList<EntitlementCriteriaOption>? = null
) {
    override fun equals(other: Any?): Boolean {
        return if (other is EntitlementCriteria) {
            id == other.id
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }
}
