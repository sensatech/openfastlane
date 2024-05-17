package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field
import java.time.LocalDate
import java.time.ZonedDateTime
import java.util.Objects

@ExcludeFromJacocoGeneratedReport
@Document(collection = "person")
class Person(
    @Id
    val id: String,

    @Field("first_name")
    var firstName: String,

    @Field("last_name")
    var lastName: String,

    @Field("date_of_birth")
    var dateOfBirth: LocalDate?,
    var gender: Gender?,
    var address: Address?,
    var email: String?,

    @Field("mobile_number")
    var mobileNumber: String?,

    @Field("similar_persons")
    var similarPersonIds: Set<String> = emptySet(),

    var comment: String = "",

    @Field("registered_at")
    var createdAt: ZonedDateTime = ZonedDateTime.now(),

    @Field("updated_at")
    var updatedAt: ZonedDateTime = ZonedDateTime.now(),

    @Field("audit")
    val audit: MutableList<AuditItem> = arrayListOf(),

    @Field("last_consumptions")
    val lastConsumptions: MutableList<ConsumptionInfo> = arrayListOf(),
) : Auditable {

    @Transient
    var entitlements: List<Entitlement>? = null

    override fun equals(other: Any?): Boolean {
        return if (other is Person) {
            id == other.id
        } else {
            false
        }
    }

    override fun hashCode(): Int {
        return Objects.hash(id)
    }

    fun summary() = "$firstName $lastName $gender ${address?.summary()} $email $mobileNumber"
}
