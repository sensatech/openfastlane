package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender

data class UpdatePerson(
    var firstName: String? = null,
    var lastName: String? = null,
    var dateOfBirth: String? = null,
    var gender: Gender? = null,
    var address: Address? = null,
    var email: String? = null,
    var mobileNumber: String? = null,
    var comment: String? = null,
)
