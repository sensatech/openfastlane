package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.entitlements.CampaignsService
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RequiresReader
@RestController
@RequestMapping("/campaigns", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class CampaignApi(
    private val service: CampaignsService,
) {

    @RequiresReader
    @GetMapping
    fun listAllCampaigns(
        @Parameter(hidden = true)
        user: OflUser
    ): List<CampaignDto> {
        return service.listAllCampaigns(user).map(Campaign::toDto)
    }

    @RequiresReader
    @GetMapping("/{id}")
    fun getCampaign(
        @Parameter(hidden = true)
        user: OflUser,

        @PathVariable(value = "id")
        id: String,
    ): CampaignDto {
        val campaign = service.getCampaign(user, id)
            ?: throw notFoundException(id)
        val causes = service.getCampaignCauses(user, id)
        return campaign.toDtoWithCauses(causes)
    }

    @RequiresReader
    @GetMapping("/{id}/causes")
    fun getCampaignCauses(
        @Parameter(hidden = true)
        user: OflUser,

        @PathVariable(value = "id")
        id: String,
    ): List<EntitlementCauseDto> {
        return service.getCampaignCauses(user, id).map(EntitlementCause::toDto)
    }

    private fun notFoundException(id: String) = NotFoundException(
        "ENTITLEMENT_CAUSE_NOT_FOUND",
        "Entitlement cause with id $id not found"
    )
}
