package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.mocks.Mocks
import at.sensatech.openfastlane.testcommons.AbstractMongoDbServiceTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired

class CampaignsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var campaignRepository: CampaignRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    lateinit var subject: CampaignsServiceImpl

    private final val campaigns = listOf(
        Mocks.mockCampaign(name = "campaigns1"),
        Mocks.mockCampaign(name = "campaigns2"),
    )
    final val firstCampaign = campaigns.first()

    private final val causes = listOf(
        Mocks.mockEntitlementCause(name = "cause1", campaignId = firstCampaign.id),
        Mocks.mockEntitlementCause(name = "cause2", campaignId = firstCampaign.id),
    )
    val firstCause = causes.first()

    @BeforeEach
    fun beforeEach() {
        subject = CampaignsServiceImpl(campaignRepository, causeRepository)
        campaignRepository.saveAll(campaigns)
        causeRepository.saveAll(causes)
    }

    @Nested
    inner class listAllCampaigns {
        @Test
        fun `listAllEntitlements should be allowed for READER`() {
            val persons = subject.listAllCampaigns(reader)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getCampaign {
        @Test
        fun `getCampaign should be allowed for READER`() {
            val persons = subject.getCampaign(reader, firstCampaign.id)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getCampaignCauses {
        @Test
        fun `getCampaignCauses should be allowed for READER`() {
            val persons = subject.getCampaignCauses(reader, firstCampaign.id)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class entitlementCauses {
        @Test
        fun `listAllEntitlementCauses should be allowed for READER`() {
            val causes = subject.listAllEntitlementCauses(reader)
            assertThat(causes).isNotNull
        }

        @Test
        fun `getEntitlementCause should be allowed for READER`() {
            val cause = subject.getEntitlementCause(reader, firstCause.id)
            assertThat(cause).isNotNull
        }
    }
}
