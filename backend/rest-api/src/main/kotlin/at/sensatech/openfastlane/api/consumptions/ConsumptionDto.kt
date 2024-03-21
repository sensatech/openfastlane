package at.sensatech.openfastlane.api.consumptions

import at.sensatech.openfastlane.api.entitlements.EntitlementValueDto
import at.sensatech.openfastlane.api.entitlements.toDto
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.EntitlementValue
import java.time.ZonedDateTime

data class ConsumptionDto(
    val id: String,
    val personId: String,
    val entitlementCauseId: String,
    val campaignId: String,
    val consumedAt: ZonedDateTime,
    val entitlementData: List<EntitlementValueDto>
)

internal fun Consumption.toDto(): ConsumptionDto = ConsumptionDto(
    id = this.id,
    personId = this.personId,
    entitlementCauseId = this.entitlementCauseId,
    campaignId = this.campaignId,
    consumedAt = this.consumedAt,
    entitlementData = entitlementData.map(EntitlementValue::toDto)
)
