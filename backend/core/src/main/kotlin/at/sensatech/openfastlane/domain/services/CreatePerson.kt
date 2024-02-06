package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender

data class CreatePerson(
    var firstName: String,
    var lastName: String,
    var dateOfBirth: String?,
    var gender: Gender?,
    var address: Address?,
    var email: String?,
    var mobileNumber: String?,
    var comment: String = "",
)
