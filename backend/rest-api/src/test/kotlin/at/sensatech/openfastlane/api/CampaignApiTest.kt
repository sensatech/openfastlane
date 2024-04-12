package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.entitlements.CampaignApi
import at.sensatech.openfastlane.api.entitlements.CampaignDto
import at.sensatech.openfastlane.api.entitlements.toDto
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.entitlements.CampaignsService
import at.sensatech.openfastlane.mocks.Mocks
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.test.context.ContextConfiguration

@WebMvcTest(controllers = [CampaignApi::class])
@ContextConfiguration(classes = [CampaignApi::class])
internal class CampaignApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/campaigns"

    @MockkBean
    private lateinit var service: CampaignsService

    private val firstOne = Mocks.mockCampaign()
    private val campaigns = listOf(firstOne, Mocks.mockCampaign())
    private val causes = listOf(Mocks.mockEntitlementCause(), Mocks.mockEntitlementCause())

    @BeforeEach
    fun beforeEach() {
        every { service.listAllCampaigns(any()) } returns campaigns
        every { service.getCampaign(any(), any()) } returns null
        every { service.getCampaign(any(), eq(firstOne.id)) } returns firstOne
        every { service.getCampaignCauses(any(), eq(firstOne.id)) } returns causes
        every { service.listAllEntitlementCauses(any()) } returns causes
    }

    @Nested
    inner class ListAllCampaigns {

        @TestAsReader
        fun `listAllCampaigns RESTDOC`() {
            performGet(testUrl)
                .expectOk()
                .document(
                    "campaigns-list",
                    responseFields(campaignFields("[]."))
                )
            verify { service.listAllCampaigns(any()) }
        }

        @TestAsReader
        fun `listAllCampaigns should return list list`() {
            val returnsList = performGet(testUrl)
                .returnsList(CampaignDto::class.java)
            verify { service.listAllCampaigns(any()) }
            assertThat(returnsList).containsExactlyElementsOf(campaigns.map {
                it.toDto(listOf())
            })
        }
    }

    @Nested
    inner class GetCampaign {

        @TestAsReader
        fun `getCampaign RESTDOC`() {
            val url = "$testUrl/${firstOne.id}"
            performGet(url)
                .expectOk()
                .document(
                    "campaigns-get",
                    responseFields(campaignFields(withCauses = true))
                )
            verify { service.getCampaign(any(), eq(firstOne.id)) }
        }

        @TestAsReader
        fun `getCampaign should return Campaign`() {
            val url = "$testUrl/${firstOne.id}"
            val result = performGet(url).returns(CampaignDto::class.java)
            assertThat(result).isEqualTo(firstOne.toDto(causes))
            verify { service.getCampaign(any(), eq(firstOne.id)) }
        }

        @TestAsReader
        fun `getCampaign should return 404`() {
            val url = "$testUrl/${newId()}"
            performGet(url).isNotFound()
        }
    }

    @TestAsReader
    fun `getCampaignCauses RESTDOC`() {
        val url = "$testUrl/${firstOne.id}/causes"
        this.performGet(url)
            .expectOk()
            .document(
                "campaign-causes-list",
                responseFields(entitlementCauseFields("[]."))
            )
        verify { service.getCampaignCauses(any(), eq(firstOne.id)) }
    }
}
