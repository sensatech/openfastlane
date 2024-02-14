package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Component

@Component
class OflDemoData : ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    lateinit var campaignRepository: CampaignRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

    @Autowired
    lateinit var personRepository: PersonRepository

    override fun onApplicationEvent(event: ApplicationReadyEvent) {

        val essensAusgabe = Campaign("65cb6c1851090750aaaaaaa0", "Essensausgabe", Period.YEARLY)
        if (campaignRepository.findByIdOrNull(essensAusgabe.id) == null) {
            campaignRepository.save(essensAusgabe)
        }

        val ma40 = EntitlementCause(
            "65cb6c1851090750aaaaabbb0",
            essensAusgabe.id,
            "MA40",
            arrayListOf(
                EntitlementCriteria("65cb6c1851090750aaaaabbc0", "Lohnzettel", EntitlementCriteriaType.TEXT, null),
                EntitlementCriteria("65cb6c1851090750aaaaabbc1", "Haushaltsgröße", EntitlementCriteriaType.TEXT, null),
            )
        )

        if (causeRepository.findByIdOrNull(ma40.id) == null) {
            causeRepository.save(ma40)
        }
    }
}
