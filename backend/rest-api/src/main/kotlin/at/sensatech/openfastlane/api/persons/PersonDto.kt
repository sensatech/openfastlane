package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Person
import java.time.LocalDate
import java.time.ZonedDateTime

data class PersonDto(
    val id: String,
    var firstName: String,
    var lastName: String,
    var birthDate: LocalDate?,
    var gender: Gender?,
    var address: Address?,
    var email: String?,
    var mobileNumber: String?,
    var comment: String,
    var createdAt: ZonedDateTime,
    var updatedAt: ZonedDateTime
)

internal fun Person.toDto(): PersonDto = PersonDto(
    id = this.id,
    firstName = this.firstName,
    lastName = this.lastName,
    birthDate = this.birthDate,
    gender = this.gender,
    address = this.address,
    email = this.email,
    mobileNumber = this.mobileNumber,
    comment = this.comment,
    createdAt = this.createdAt,
    updatedAt = this.updatedAt
)
