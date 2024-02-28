package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import java.util.Objects

@ExcludeFromJacocoGeneratedReport
@Document
class Campaign(
    @Id
    val id: String,
    var name: String,
    var period: Period
) {
    override fun equals(other: Any?): Boolean {
        return if (other is Campaign) {
            id == other.id
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }
}
