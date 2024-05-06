package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.config.OflConfiguration
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaOption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.core.io.FileSystemResource
import org.springframework.stereotype.Component

@Component
class NecessaryStartupDataInitializer : ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    lateinit var campaignRepository: CampaignRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    @Autowired
    lateinit var objectMapper: ObjectMapper

    @Autowired
    lateinit var oflConfiguration: OflConfiguration

    override fun onApplicationEvent(event: ApplicationReadyEvent) {

        val finalPath = oflConfiguration.configDataDir + "/campaigns.json"

        val imgFile = FileSystemResource("Y:/Kevin/downloads/pic_mountain.jpg")

        val essensAusgabe = Campaign("65cb6c1851090750aaaaaaa0", "Lebensmittelausgabe", Period.YEARLY)
        val schulstart = Campaign("65cb6c1851090750aaaaaaa1", "Schulstartaktion", Period.YEARLY)
        campaignRepository.save(essensAusgabe)
        campaignRepository.save(schulstart)

        val ma40 = EntitlementCause(
            "65cb6c1851090750aaaaabbb0",
            essensAusgabe.id,
            "MA40",
            arrayListOf(
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc0",
                    "Lohnzettel",
                    EntitlementCriteriaType.TEXT,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc1",
                    "Haushaltsgröße",
                    EntitlementCriteriaType.TEXT,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc2",
                    "Haushaltseinkommen",
                    EntitlementCriteriaType.FLOAT,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc3",
                    "Einkommensnachweis",
                    EntitlementCriteriaType.OPTIONS,
                    null,
                    arrayListOf(
                        EntitlementCriteriaOption(
                            "Lohnzettel", "Lohnzettel",
                        ),
                        EntitlementCriteriaOption(
                            "MA", "MA",
                        ),
                    ),
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc4",
                    "Kommentar",
                    EntitlementCriteriaType.TEXT,
                    null
                ),
            )
        )

        val ukraine = EntitlementCause(
            "65cb6c1851090750aaaaabbbaf",
            essensAusgabe.id,
            "Ukraine",
            arrayListOf(
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba3",
                    "Ukrainische Staatsbürgerschaft",
                    EntitlementCriteriaType.CHECKBOX,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba4",
                    "Lohnzettel",
                    EntitlementCriteriaType.CHECKBOX,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba5",
                    "Haushaltsgröße",
                    EntitlementCriteriaType.INTEGER,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba6",
                    "Haushaltseinkommen",
                    EntitlementCriteriaType.FLOAT,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba7",
                    "Kommentar 1",
                    EntitlementCriteriaType.TEXT,
                    null
                ),
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabba8",
                    "Kommentar 2",
                    EntitlementCriteriaType.TEXT,
                    null
                ),
            )
        )

        causeRepository.save(ukraine)
        causeRepository.save(ma40)
    }
}
