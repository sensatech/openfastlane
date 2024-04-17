package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.consumptions.ConsumptionDto
import at.sensatech.openfastlane.api.consumptions.ConsumptionsApi
import at.sensatech.openfastlane.api.consumptions.toDto
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.models.Consumption
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.core.io.ResourceLoader
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.restdocs.request.RequestDocumentation.parameterWithName
import org.springframework.restdocs.request.RequestDocumentation.queryParameters
import org.springframework.test.context.ContextConfiguration
import java.io.File
import java.time.ZoneId
import java.time.ZonedDateTime

@WebMvcTest(controllers = [ConsumptionsApi::class])
@ContextConfiguration(classes = [ConsumptionsApi::class])
internal class ConsumptionsApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/consumptions"

    @Autowired
    lateinit var resourceLoader: ResourceLoader

    @MockkBean
    private lateinit var service: ConsumptionsService

    private val consumedAt = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
    private val consumptions = mockConsumptions(entitlements, consumedAt)

    @BeforeEach
    fun beforeEach() {
        every { service.findConsumptions(any(), any(), any(), any(), any(), any()) } returns consumptions

        val dataFile: File = resourceLoader.getResource("classpath:example.pdf").file
        every { service.exportConsumptions(any(), any(), any(), any(), any()) } returns FileResult(
            "example.pdf",
            "classpath:example.pdf",
            file = dataFile
        )
    }

    @Nested
    inner class FindConsumptions {

        @TestAsReader
        fun `findConsumptions RESTDOC`() {
            val campaignId = newId()
            val causeId = newId()
            val personId = newId()
            val from = ZonedDateTime.now()
            val to = ZonedDateTime.now()
            performGet("$testUrl/find?campaignId=$campaignId&causeId=$causeId&personId=$personId&from=$from&to=$to")
                .expectOk()
                .document(
                    "consumptions-find",
                    responseFields(consumptionFields("[].")),
                    queryParameters(
                        parameterWithName("campaignId").description("Id of Campaign (nullable)").optional(),
                        parameterWithName("causeId").description("Id of EntitlementCause (nullable)").optional(),
                        parameterWithName("personId").description("Id of Person (nullable)").optional(),
                        parameterWithName("from").description("ZonedDateTime (nullable)").optional(),
                        parameterWithName("to").description("ZonedDateTime (nullable)").optional(),
                    )
                )
            verify { service.findConsumptions(any(), eq(campaignId), eq(causeId), eq(personId), eq(from), eq(to)) }
        }

        @TestAsReader
        fun `listAllCampaigns should return list`() {
            val campaignId = newId()
            val causeId = newId()
            val personId = newId()
            val from = ZonedDateTime.now()
            val to = ZonedDateTime.now()
            val returnsList =
                performGet("$testUrl/find?campaignId=$campaignId&causeId=$causeId&personId=$personId&from=$from&to=$to").returnsList(
                    ConsumptionDto::class.java
                )

            verify {
                service.findConsumptions(
                    any(),
                    eq(campaignId),
                    eq(causeId),
                    eq(personId),
                    withArg { assertDateTime(it).isApproximately(from) },
                    withArg { assertDateTime(it).isApproximately(to) }
                )
                assertThat(returnsList.map { it.copy(consumedAt = consumedAt) }).containsExactlyElementsOf(
                    consumptions.map(Consumption::toDto).map { it.copy(consumedAt = consumedAt) }
                )
            }
        }
    }

    @Nested
    inner class ExportConsumptions {

        @TestAsManager
        fun `exportConsumptions RESTDOC`() {
            val campaignId = newId()
            val causeId = newId()
            val from = ZonedDateTime.now()
            val to = ZonedDateTime.now()
            performGet("$testUrl/export?campaignId=$campaignId&causeId=$causeId&from=$from&to=$to")
                .expectOk()
                .document(
                    "consumptions-export",
                    queryParameters(
                        parameterWithName("campaignId").description("Id of Campaign (nullable)").optional(),
                        parameterWithName("causeId").description("Id of EntitlementCause (nullable)").optional(),
                        parameterWithName("from").description("ZonedDateTime (nullable)").optional(),
                        parameterWithName("to").description("ZonedDateTime (nullable)").optional(),
                    )
                )
            verify { service.exportConsumptions(any(), eq(campaignId), eq(causeId), eq(from), eq(to)) }
        }

        @TestAsReader
        fun `exportConsumptions should not be allowed for READER`() {
            val campaignId = newId()
            val causeId = newId()
            val from = ZonedDateTime.now()
            val to = ZonedDateTime.now()
            performGet("$testUrl/export?campaignId=$campaignId&causeId=$causeId&from=$from&to=$to")
                .expectForbidden()

            verify(exactly = 0) { service.exportConsumptions(any(), eq(campaignId), eq(causeId), eq(from), eq(to)) }
        }
    }
}
