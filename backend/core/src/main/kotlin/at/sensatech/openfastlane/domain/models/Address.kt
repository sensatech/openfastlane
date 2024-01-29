package at.sensatech.openfastlane.domain.models

data class Address(
        val street: String,
        val city: String,
        val state: String,
        val zipCode: String
)