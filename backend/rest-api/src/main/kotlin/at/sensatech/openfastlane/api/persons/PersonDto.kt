package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.api.entitlements.EntitlementDto
import at.sensatech.openfastlane.api.entitlements.toDto
import at.sensatech.openfastlane.domain.models.ConsumptionInfo
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Person
import java.time.LocalDate
import java.time.ZonedDateTime

data class PersonDto(
    val id: String,
    var firstName: String,
    var lastName: String,
    var dateOfBirth: LocalDate?,
    var gender: Gender?,
    var address: AddressDto?,
    var email: String?,
    var mobileNumber: String?,
    var comment: String,
    var similarPersonIds: Set<String>,
    var createdAt: ZonedDateTime,
    var updatedAt: ZonedDateTime,
    var entitlements: List<EntitlementDto>? = null,
    var lastConsumptions: MutableList<ConsumptionInfo>? = null,
)

internal fun Person.toDto(
    withEntitlements: Boolean = false,
    withLastConsumptions: Boolean = false
): PersonDto = PersonDto(
    id = this.id,
    firstName = this.firstName,
    lastName = this.lastName,
    dateOfBirth = this.dateOfBirth,
    gender = this.gender,
    address = this.address?.toDto(),
    email = this.email,
    mobileNumber = this.mobileNumber,
    comment = this.comment,
    similarPersonIds = this.similarPersonIds,
    createdAt = this.createdAt,
    updatedAt = this.updatedAt,
    entitlements = if (withEntitlements) this.entitlements?.map { it.toDto() } else null,
    lastConsumptions = if (withLastConsumptions) this.lastConsumptions else null,
)
