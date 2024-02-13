package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.security.OflUser

interface CampaignsService {

    fun listAllCampaigns(user: OflUser): List<Campaign>
    fun getCampaign(user: OflUser, campaignId: String): Campaign?

    fun getCampaignCauses(user: OflUser, campaignId: String): List<EntitlementCause>

    fun listAllEntitlementCauses(user: OflUser): List<EntitlementCause>
    fun getEntitlementCause(user: OflUser, causeId: String): EntitlementCause?
}
