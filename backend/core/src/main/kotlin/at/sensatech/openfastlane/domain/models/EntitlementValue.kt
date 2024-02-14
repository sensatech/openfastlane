package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document
import java.util.Objects

@Document
class EntitlementValue(
    val criteriaId: String,
    val type: EntitlementCriteriaType,
    var value: Any
) {
    override fun equals(other: Any?): Boolean {
        return if (other is EntitlementValue) {
            criteriaId == other.criteriaId
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(criteriaId)
    }
}
