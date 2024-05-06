package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaOption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import com.fasterxml.jackson.databind.ObjectMapper
import io.mockk.Ordering
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.bson.types.ObjectId
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.core.io.Resource
import org.springframework.core.io.ResourceLoader
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.junit.jupiter.SpringExtension

@ExtendWith(value = [SpringExtension::class])
@ActiveProfiles(ApplicationProfiles.TEST)
@ContextConfiguration(classes = [])
class StartupConfigurationServiceImplTest {

    @Autowired
    private val resourceLoader: ResourceLoader? = null

    private val objectMapper: ObjectMapper = TestSimpleJsonObjectMapper.create()

    val campaignRepository: CampaignRepository = mockk(relaxed = true) {
        every { save(any()) } answers { firstArg() }
    }

    private val causeRepository: EntitlementCauseRepository = mockk(relaxed = true) {
        every { save(any()) } answers { firstArg() }
    }

    val subject: StartupConfigurationServiceImpl =
        StartupConfigurationServiceImpl(campaignRepository, causeRepository, objectMapper)

    @Nested
    inner class ParseCampaigns {

        private lateinit var campaignsJsonResource: Resource

        @BeforeEach
        fun beforeEach() {
            campaignsJsonResource = resourceLoader!!.getResource("classpath:campaigns.json")
        }

        @Test
        fun `parseCampaigns should parse campaigns and save them`() {
            val content = campaignsJsonResource.inputStream.bufferedReader().use { it.readText() }
            subject.parseCampaigns(content)

            verify(ordering = Ordering.ORDERED) {
                campaignRepository.save(
                    Campaign(
                        ObjectId("65cb6c1851090750aaaaaaa0").toString(),
                        "Lebensmittelausgabe",
                        Period.YEARLY
                    )
                )

                campaignRepository.save(
                    Campaign(
                        ObjectId("65cb6c1851090750aaaaaaa1").toString(),
                        "Schulstartaktion",
                        Period.YEARLY
                    )
                )
            }
        }
    }

    @Nested
    inner class ParseCampaignNode {

        @Test
        fun `parseCampaignNode should parse campaigns and save them`() {
            val jsonResource = resourceLoader!!.getResource("classpath:campaigns_1.json")
            val content = jsonResource.inputStream.bufferedReader().use { it.readText() }
            val first = objectMapper.readTree(content)
            subject.parseCampaignNode(first)

            verify {
                campaignRepository.save(
                    Campaign(
                        ObjectId("65cb6c1851090750aaaaaaa0").toString(),
                        "Lebensmittelausgabe",
                        Period.YEARLY
                    )
                )
            }

            verify {
                causeRepository.save(any())
            }
        }
    }

    @Nested
    inner class ParseCampaignCauseNode {

        @Test
        fun `parseCampaignCauseNode should parse every EntitlementCriteriaType`() {
            val jsonResource = resourceLoader!!.getResource("classpath:campaigns_cause_1.json")
            val content = jsonResource.inputStream.bufferedReader().use { it.readText() }
            val first = objectMapper.readTree(content)
            val result = subject.parseCampaignCauseNode(first)

            val expected = EntitlementCause(
                "65cb6c1851090750aaaaabbb0",
                "65cb6c1851090750aaaaaaa0",
                "MA40",
                criterias = mutableListOf(
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc0",
                        "Lohnzettel",
                        EntitlementCriteriaType.TEXT,
                        null,
                        null,
                    ),
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc1",
                        "Haushaltsgröße",
                        EntitlementCriteriaType.FLOAT,
                        null,
                        null,
                    ),
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc2",
                        "Haushaltseinkommen",
                        EntitlementCriteriaType.CURRENCY,
                        null,
                        null,
                    ),
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc3",
                        "Menschen",
                        EntitlementCriteriaType.INTEGER,
                        null,
                        null,
                    ),
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc4",
                        "Kommentar",
                        EntitlementCriteriaType.CHECKBOX,
                        null,
                        null,
                    )
                )
            )
            assertThat(result).isEqualTo(expected)

            verify {
                causeRepository.save(expected)
            }
        }

        @Test
        fun `parseCampaignCauseNode should parse nullable reportKey`() {
            val jsonResource = resourceLoader!!.getResource("classpath:campaigns_cause_2.json")
            val content = jsonResource.inputStream.bufferedReader().use { it.readText() }
            val first = objectMapper.readTree(content)
            val result = subject.parseCampaignCauseNode(first)

            val expected = EntitlementCause(
                "65cb6c1851090750aaaaabbb0",
                "65cb6c1851090750aaaaaaa0",
                "MA40",
                criterias = mutableListOf(
                    EntitlementCriteria(
                        "65cb6c1851090750aaaaabbc0",
                        "Lohnzettel",
                        EntitlementCriteriaType.TEXT,
                        "reportKey",
                        null,
                    )
                )
            )
            assertThat(result).isEqualTo(expected)

            verify {
                causeRepository.save(expected)
            }
        }
    }

    @Nested
    inner class ParseCauseCriteriaNode {

        @Test
        fun `parseCauseCriteriaNode should parse OPTIONS with nullable descriptions`() {
            val jsonResource = resourceLoader!!.getResource("classpath:campaigns_cause_criteria_1.json")
            val content = jsonResource.inputStream.bufferedReader().use { it.readText() }
            val first = objectMapper.readTree(content)
            val result = subject.parseCauseCriteriaNode(first)

            assertThat(result).isEqualTo(
                EntitlementCriteria(
                    "65cb6c1851090750aaaaabbc3",
                    "Einkommensnachweis",
                    EntitlementCriteriaType.OPTIONS,
                    null,
                    mutableListOf(
                        EntitlementCriteriaOption(
                            "Lohnzettel",
                            "Lohnzettel",
                            0,
                            null
                        ),
                        EntitlementCriteriaOption(
                            "MA",
                            "MA",
                            1,
                            "description"
                        )
                    )
                )
            )
        }

        @Test
        fun `parseCauseCriteriaNode should parse OPTIONS and return null if empty list`() {
            val jsonResource = resourceLoader!!.getResource("classpath:campaigns_cause_criteria_2.json")
            val content = jsonResource.inputStream.bufferedReader().use { it.readText() }
            val first = objectMapper.readTree(content)
            val result = subject.parseCauseCriteriaNode(first)

            assertThat(result).isEqualTo(null)
        }
    }
}
