package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria

data class EntitlementCauseDto(
    val id: String,
    val campaignId: String,
    val criterias: List<EntitlementCriteriaDto>
)

internal fun EntitlementCause.toDto(): EntitlementCauseDto = EntitlementCauseDto(
    id = this.id,
    campaignId = this.campaignId,
    criterias = this.criterias.map(EntitlementCriteria::toDto)
)
