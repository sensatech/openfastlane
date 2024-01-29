package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document
import java.util.*

@Document
data class Consumption(
        val createdAt: Date,
        val updatedAt: Date,
        val validUntil: Date
)