package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.springframework.data.mongodb.core.mapping.Document
import java.time.ZonedDateTime

@ExcludeFromJacocoGeneratedReport
@Document
data class Consumption(
    val id: String,
    val personId: String,
    val entitlementCauseId: String,
    val campaignId: String,
    val consumedAt: ZonedDateTime,
    val entitlementData: List<EntitlementValue> = emptyList(),
)
