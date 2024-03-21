package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.consumptions.ConsumptionDto
import at.sensatech.openfastlane.api.consumptions.ConsumptionsApi
import at.sensatech.openfastlane.api.consumptions.toDto
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.models.Consumption
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.restdocs.request.RequestDocumentation.parameterWithName
import org.springframework.restdocs.request.RequestDocumentation.queryParameters
import org.springframework.test.context.ContextConfiguration
import java.time.ZoneId
import java.time.ZonedDateTime

@WebMvcTest(controllers = [ConsumptionsApi::class])
@ContextConfiguration(classes = [ConsumptionsApi::class])
internal class ConsumptionsApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/consumptions"

    @MockkBean
    private lateinit var service: ConsumptionsService

    private val consumedAt = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
    private val consumptions = mockConsumptions(entitlements, consumedAt)

    @BeforeEach
    fun beforeEach() {
        every { service.findConsumptions(any(), any(), any(), any(), any(), any()) } returns consumptions
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
}
