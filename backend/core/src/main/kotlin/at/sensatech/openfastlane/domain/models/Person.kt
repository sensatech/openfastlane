package at.sensatech.openfastlane.domain.models

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document
import org.springframework.data.mongodb.core.mapping.Field
import java.time.LocalDate
import java.time.ZonedDateTime
import java.util.*


@Document(collection = "person")
class Person(
    @Id
    val id: String,

    @Field("first_name")
    var firstName: String,

    @Field("last_name")
    var lastName: String,

    @Field("birth_date")
    var birthDate: LocalDate?,
    var gender: Gender?,
    var address: Address?,
    var email: String?,

    @Field("mobile_number")
    var mobileNumber: String?,


    var comment: String = "",

    @Field("registered_at")
    var createdAt: ZonedDateTime = ZonedDateTime.now(),

    @Field("updated_at")
    var updatedAt: ZonedDateTime = ZonedDateTime.now()
) {
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
}

enum class Gender {
    MALE, FEMALE, DIVERSE
}