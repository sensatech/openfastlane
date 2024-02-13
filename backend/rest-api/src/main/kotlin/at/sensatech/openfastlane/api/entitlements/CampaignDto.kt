package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.Period

data class CampaignDto(
    val id: String,
    val name: String,
    val period: Period,
    val causes: List<EntitlementCauseDto>? = null

)

internal fun Campaign.toDto(): CampaignDto = CampaignDto(
    id = this.id,
    name = this.name,
    period = this.period,
    causes = null,
)

internal fun Campaign.toDtoWithCauses(causes: List<EntitlementCause>): CampaignDto = CampaignDto(
    id = this.id,
    name = this.name,
    period = this.period,
    causes = causes.map(EntitlementCause::toDto)
)
