package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Period
import org.springframework.beans.factory.annotation.Autowired

internal class CampaignRepositoryTest :
    AbstractRepositoryTest<Campaign, String, CampaignRepository>() {

    @Autowired
    override lateinit var repository: CampaignRepository

    override fun createDefaultEntityPair(id: String): Pair<String, Campaign> {
        val entitlement = Campaign(id, "name", period = Period.YEARLY)
        return Pair(id, entitlement)
    }

    override fun changeEntity(entity: Campaign) = entity.apply {
        period = Period.MONTHLY
    }
}
