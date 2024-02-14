package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.services.AdminPermissions
import at.sensatech.openfastlane.security.OflUser
import at.sensatech.openfastlane.security.UserRole
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service

@Service
class CampaignsServiceImpl(
    private val campaignRepository: CampaignRepository,
    private val causeRepository: EntitlementCauseRepository,
) : CampaignsService {
    override fun listAllCampaigns(user: OflUser): List<Campaign> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return campaignRepository.findAll()
    }

    override fun getCampaign(user: OflUser, campaignId: String): Campaign? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return campaignRepository.findByIdOrNull(campaignId)
    }

    override fun getCampaignCauses(user: OflUser, campaignId: String): List<EntitlementCause> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        campaignRepository.findByIdOrNull(campaignId)
            ?: throw IllegalArgumentException("Campaign not found")

        return causeRepository.findAll()
    }

    override fun listAllEntitlementCauses(user: OflUser): List<EntitlementCause> {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return causeRepository.findAll()
    }

    override fun getEntitlementCause(user: OflUser, causeId: String): EntitlementCause? {
        AdminPermissions.assertPermission(user, UserRole.READER)
        return causeRepository.findByIdOrNull(causeId)
    }
}
