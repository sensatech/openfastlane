package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.mongodb.core.mapping.Document
import java.util.Date

@ExcludeFromJacocoGeneratedReport
@Document
data class Consumption(
    val createdAt: Date,
    val updatedAt: Date,
    val validUntil: Date
)
