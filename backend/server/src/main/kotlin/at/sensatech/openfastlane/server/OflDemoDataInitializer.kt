package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import org.slf4j.LoggerFactory
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service
import java.time.LocalDate
import kotlin.math.roundToInt

@Service
class OflDemoDataInitializer(
    private val campaignRepository: CampaignRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val entitlementRepository: EntitlementRepository,
    private val personRepository: PersonRepository,
) {

    fun insertDemoData() {
        val essensAusgabe = campaignRepository.findByIdOrNull("65cb6c1851090750aaaaaaa0")
        val ma40 = causeRepository.findByIdOrNull("65cb6c1851090750aaaaabbb0")

        if (essensAusgabe == null || ma40 == null) {
            log.error("Campaign 'Essensausgabe' or EntitlementCause 'ma40' not found!")
            log.error("Cannot run demo data initializer! See ENV VAR 'OFL_DEMO_DATA' for more info.")
            return
        }

        createPersons(essensAusgabe, ma40)
    }

    private fun createPersons(
        essensAusgabe: Campaign,
        ma40: EntitlementCause
    ) {

        val maxPersons = 100
        for (i in 1..maxPersons) {
            val idSuffix = i.toString().padStart(4, '0')
            val id = idStartPrefix + idSuffix

            if (personRepository.findByIdOrNull(id) == null) {
                val firstName = firstNames.random()
                val lastName = lastNames.random()
                val person = Person(
                    id,
                    firstName,
                    lastName,
                    LocalDate.of(
                        birthYear.random(),
                        (Math.random() * 11 + 1).roundToInt(),
                        (Math.random() * 27 + 1).roundToInt()
                    ),
                    if (i % 20 == 0) Gender.DIVERSE else if (i % 2 == 0) Gender.MALE else Gender.FEMALE,
                    Address(
                        streetNames.random(),
                        (Math.random() * 100 + 1).roundToInt().toString(),
                        plz.random(),
                        "123412345"
                    ),
                    "$firstName.$lastName@example.com",
                    "123456789",
                )
                log.info("TEST Create person: $person")
                personRepository.save(person)
            }
            if (i % 3 != 0) {
                if (entitlementRepository.findByIdOrNull(id) == null) {
                    val entitlement = Entitlement(
                        id,
                        essensAusgabe.id,
                        ma40.id,
                        id,
                        EntitlementStatus.PENDING,
                        arrayListOf(
                            EntitlementValue(
                                "65cb6c1851090750aaaaabbc0",
                                EntitlementCriteriaType.CHECKBOX,
                                "true",
                            ),
                            EntitlementValue(
                                "65cb6c1851090750aaaaabbc1",
                                EntitlementCriteriaType.INTEGER,
                                "2"
                            ),
                            EntitlementValue(
                                "65cb6c1851090750aaaaabbc2",
                                EntitlementCriteriaType.FLOAT,
                                "2500"
                            ),
                            EntitlementValue(
                                "65cb6c1851090750aaaaabbc3",
                                EntitlementCriteriaType.OPTIONS,
                                "Lohnzettel"
                            ),
                            EntitlementValue(
                                "65cb6c1851090750aaaaabbc4",
                                EntitlementCriteriaType.TEXT,
                                "ist lustig"
                            ),
                        ),
                    )

                    log.info("TEST Create entitlement: $entitlement")
                    entitlementRepository.save(entitlement)
                }
            }
        }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
        private val idStartPrefix = "65cb6c1851090750dddd" // 4 Chars left
        private val firstNames = listOf(
            "John",
            "Jane",
            "Max",
            "Anna",
            "Peter",
            "Paul",
            "Maria",
            "Hans",
            "Karl",
            "Eva",
            "Lukas",
            "Lena",
            "Fritz",
            "Frieda",
            "Hilde",
            "Hugo",
            "Hermann",
            "Heinz",
            "Helga"
        )
        private val lastNames = listOf(
            "Doe",
            "Power",
            "Müller",
            "Schmidt",
            "Huber",
            "Wagner",
            "Pichler",
            "Gruber",
            "Winkler",
            "Steiner",
            "Bauer",
            "Weber",
            "Leitner",
            "Berger",
            "Fischer",
            "Schmid",
            "Eder",
            "Reiter",
            "Hofer"
        )
        private val birthYear = listOf(
            1980,
            1981,
            1982,
            1983,
            1984,
            1985,
            1986,
            1987,
            1988,
            1989,
            1990,
            1991,
            1992,
            1993,
            1994,
            1995,
            1996,
            1997,
            1998,
            1999
        )
        private val plz = listOf(
            "1010",
            "1020",
            "1030",
            "1040",
            "1050",
            "1060",
            "1070",
            "1080",
            "1090",
            "1100",
            "1110",
            "1120",
            "1130",
            "1140",
            "1150",
            "1160",
            "1170",
            "1180",
            "1190",
            "1200",
            "1210",
            "1220",
            "1230"
        )
        private val streetNames = listOf("Hausgasse", "Testplatz", "Demogasse", "Autostraße", "Parkallee")
    }
}
