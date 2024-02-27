package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Component
import java.time.LocalDate

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
            )
        )

        if (causeRepository.findByIdOrNull(ma40.id) == null) {
            causeRepository.save(ma40)
        }

        val address1 = Address("Hausgasse 1", "5", "1010", "123412345")
        val address2 = Address("Hausgasse 1", "7", "1010", "123412345")
        val address3 = Address("Hausgasse 5", "26", "1010", "123412347")
        val johnDoe = Person(
            "65cb6c1851090750dddd0001", "John", "Doe",
            LocalDate.of(1980, 10, 10),
            Gender.MALE,
            address1,
            "email@example.com",
            "123456789",
        )

        val janeDoe = Person(
            "65cb6c1851090750dddd0002", "Jane", "Doe",
            LocalDate.of(1980, 10, 10),
            Gender.MALE,
            address2,
            "email@example.com",
            "123456789",
        )
        val maxPower = Person(
            "65cb6c1851090750dddd0003", "Max", "Power",
            LocalDate.of(1977, 10, 10),
            Gender.MALE,
            address2,
            "email@example.com",
            "123456789",
        )

        val maxEntitlement = Entitlement(
            "65cb6c1851090750eeee0001",
            essensAusgabe.id,
            ma40.id,
            maxPower.id,
            arrayListOf(
                EntitlementValue(
                    "65cb6c1851090750eeee0002",
                    EntitlementCriteriaType.TEXT,
                    "Lohnzettel",
                ),
                EntitlementValue(
                    "65cb6c1851090750eeee0003",
                    EntitlementCriteriaType.TEXT,
                    "Haushaltsgröße"
                ),
            )
        )

        if (personRepository.findByIdOrNull(johnDoe.id) == null) personRepository.save(johnDoe)
        if (personRepository.findByIdOrNull(janeDoe.id) == null) personRepository.save(janeDoe)
        if (personRepository.findByIdOrNull(maxPower.id) == null) personRepository.save(maxPower)
        if (entitlementRepository.findByIdOrNull(maxEntitlement.id) == null) entitlementRepository.save(
            maxEntitlement
        )


    }
}
