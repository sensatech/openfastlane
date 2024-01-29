package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document
import java.util.*


@Document
data class Person(
        val firstName: String,
        val lastName: String,
        val gender: String,
        val address: Address,
        val email: String?,
        val mobileNumber: String?,
        val birthDate: Date,
        val comment: String,
        val registeredAt: Date
)