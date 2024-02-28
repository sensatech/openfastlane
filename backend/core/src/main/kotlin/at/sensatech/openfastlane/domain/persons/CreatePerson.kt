package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender

@ExcludeFromJacocoGeneratedReport
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
