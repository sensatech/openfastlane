package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.entitlements.EntitlementsApi
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibilityType
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.entitlements.UpdateEntitlement
import at.sensatech.openfastlane.domain.exceptions.BadRequestException
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.core.io.ResourceLoader
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType
import org.springframework.restdocs.payload.JsonFieldType.STRING
import org.springframework.restdocs.payload.PayloadDocumentation.requestFields
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.test.context.ContextConfiguration
import java.io.File
import java.time.ZoneId
import java.time.ZonedDateTime

@WebMvcTest(controllers = [EntitlementsApi::class])
@ContextConfiguration(classes = [EntitlementsApi::class])
internal class EntitlementsApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/entitlements"

    @MockkBean
    private lateinit var service: EntitlementsService

    @MockkBean
    private lateinit var consumptionsService: ConsumptionsService

    @Autowired
    lateinit var resourceLoader: ResourceLoader

    private val firstOne = entitlements.first()
    private val consumedAt = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
    private val consumptions = mockConsumptions(entitlements, consumedAt)

    @BeforeEach
    fun beforeEach() {
        every { service.listAllEntitlements(any()) } returns entitlements
        every { service.getEntitlement(any(), any()) } returns null
        every { service.getEntitlement(any(), eq(firstOne.id)) } returns firstOne
        every { service.createEntitlement(any(), any()) } returns firstOne
        every { service.updateEntitlement(any(), any(), any()) } throws EntitlementsError.NoEntitlementFound("NOPE")
        every { service.updateEntitlement(any(), eq(firstOne.id), any()) } returns firstOne

        every { service.extendEntitlement(any(), any()) } throws EntitlementsError.NoEntitlementFound("NOPE")
        every { service.extendEntitlement(any(), eq(firstOne.id)) } returns firstOne
        every { service.updateQrCode(any(), any()) } throws EntitlementsError.NoEntitlementFound("NOPE")
        every { service.updateQrCode(any(), eq(firstOne.id)) } returns firstOne
        every { service.viewQrPdf(any(), any()) } throws EntitlementsError.NoEntitlementFound("NOPE")

        val dataFile: File = resourceLoader.getResource("classpath:example.pdf").file
        every { service.viewQrPdf(any(), eq(firstOne.id)) } returns FileResult(
            "example.pdf",
            "classpath:example.pdf",
            file = dataFile
        )

        every {
            consumptionsService.checkConsumptionPossibility(any(), any())
        } throws EntitlementsError.NoEntitlementFound("NOPE")

        every {
            consumptionsService.checkConsumptionPossibility(any(), eq(firstOne.id))
        } returns ConsumptionPossibility(ConsumptionPossibilityType.CONSUMPTION_POSSIBLE)

        every {
            consumptionsService.getConsumptionsOfEntitlement(any(), eq(firstOne.id))
        } returns consumptions

        every { consumptionsService.getConsumption(any(), eq(consumptions.first().id)) } returns consumptions.first()
    }

    @TestAsReader
    fun `listAllEntitlements RESTDOC`() {
        this.performGet(testUrl)
            .expectOk()
            .document(
                "entitlements-list",
                responseFields(entitlementFields("[]."))
            )
        verify { service.listAllEntitlements(any()) }
    }

    @TestAsReader
    fun `getEntitlement RESTDOC`() {
        val url = "$testUrl/${firstOne.id}"
        this.performGet(url)
            .expectOk()
            .document(
                "entitlements-get",
                responseFields(entitlementFields())
            )
        verify { service.getEntitlement(any(), eq(firstOne.id)) }
    }

    @TestAsReader
    fun `getEntitlement should return 404`() {
        val url = "$testUrl/${newId()}"
        this.performGet(url).isNotFound()
    }

    @Nested
    inner class CheckConsumptionPossibility {
        @TestAsManager
        fun `checkConsumptionPossibility RESTDOC`() {
            val url = "$testUrl/${firstOne.id}/can-consume"
            performGet(url)
                .expectOk()
                .document(
                    "entitlements-can-consume",
                    responseFields(consumptionPossibilityFields())
                )
            verify { consumptionsService.checkConsumptionPossibility(any(), eq(firstOne.id)) }
        }

        @TestAsManager
        fun `checkConsumptionPossibility should return 404`() {
            val url = "$testUrl/${newId()}/can-consume"
            performGet(url).isNotFound()
        }

        @TestAsReader
        fun `checkConsumptionPossibility should return encoded ConsumptionPossibility`() {
            val url = "$testUrl/${firstOne.id}/can-consume"
            val result: ConsumptionPossibility = performGet(url).returns()
            assertThat(result.status).isEqualTo(ConsumptionPossibilityType.CONSUMPTION_POSSIBLE)
        }

        @TestAsReader
        fun `checkConsumptionPossibility should be allowed for READER`() {
            val url = "$testUrl/${firstOne.id}/can-consume"
            performGet(url).expectOk()
            verify { consumptionsService.checkConsumptionPossibility(any(), eq(firstOne.id)) }
        }
    }

    @Nested
    inner class GetConsumptionsOfEntitlement {
        @TestAsManager
        fun `getConsumptionsOfEntitlement RESTDOC`() {
            val url = "$testUrl/${firstOne.id}/consumptions"
            performGet(url)
                .expectOk()
                .document(
                    "entitlements-get-consumptions-list",
                    responseFields(consumptionFields("[]."))
                )
            verify { consumptionsService.getConsumptionsOfEntitlement(any(), eq(firstOne.id)) }
        }

        @TestAsManager
        fun `getConsumptionsOfEntitlement should return 404`() {
            val url = "$testUrl/${newId()}/consumptions"
            performGet(url).isNotFound()
        }

        @TestAsReader
        fun `getConsumptionsOfEntitlement should be allowed for READER`() {
            val url = "$testUrl/${firstOne.id}/consumptions"
            val result = performGet(url).expectOk().returnsList(Consumption::class.java)
            verify { consumptionsService.getConsumptionsOfEntitlement(any(), eq(firstOne.id)) }
            val bla = ZonedDateTime.now()
            assertThat(result.map { it.copy(consumedAt = bla) })
                .containsExactlyElementsOf(consumptions.map { it.copy(consumedAt = bla) })
        }
    }

    @Nested
    inner class PerformConsumption {
        @TestAsManager
        fun `performConsumption RESTDOC`() {
            every { consumptionsService.performConsumption(any(), eq(firstOne.id)) } returns consumptions.first()

            val url = "$testUrl/${firstOne.id}/consume"
            performPost(url)
                .expectOk()
                .document(
                    "entitlements-perform-consumption",
                    responseFields(consumptionFields())
                )
            verify { consumptionsService.performConsumption(any(), eq(firstOne.id)) }
        }

        @TestAsManager
        fun `performConsumption should return 404`() {
            val url = "$testUrl/${newId()}/consume"
            performPost(url).isNotFound()
        }

        @TestAsReader
        fun `performConsumption should not be allowed for READER`() {
            every { consumptionsService.performConsumption(any(), eq(firstOne.id)) } returns consumptions.first()

            val url = "$testUrl/${firstOne.id}/consume"
            performPost(url).expectForbidden()
        }
    }

    @Nested
    inner class GetConsumption {
        @TestAsManager
        fun `getConsumption RESTDOC`() {
            val url = "$testUrl/${firstOne.id}/consumptions/${consumptions.first().id}"
            performGet(url)
                .expectOk()
                .document(
                    "entitlements-get-consumptions-get",
                    responseFields(consumptionFields())
                )
            verify { consumptionsService.getConsumption(any(), eq(consumptions.first().id)) }
        }

        @TestAsManager
        fun `getConsumption should return 404`() {
            val url = "$testUrl/${newId()}/consumptions/${newId()}"
            performGet(url).isNotFound()
        }

        @TestAsReader
        fun `getConsumption should be allowed for READER`() {
            val url = "$testUrl/${firstOne.id}/consumptions/${consumptions.first().id}"
            val result: Consumption = performGet(url).expectOk().returns()
            verify { consumptionsService.getConsumption(any(), eq(consumptions.first().id)) }
            assertThat(result.id).isEqualTo(consumptions.first().id)
            assertThat(result.personId).isEqualTo(consumptions.first().personId)
            assertThat(result.entitlementCauseId).isEqualTo(consumptions.first().entitlementCauseId)
            assertThat(result.entitlementData).isEqualTo(consumptions.first().entitlementData)
        }
    }

    @Nested
    inner class CreateEntitlement {

        private val request = CreateEntitlement(
            personId = newId(),
            entitlementCauseId = newId(),
            values = listOf(
                EntitlementValue(
                    criteriaId = newId(),
                    type = EntitlementCriteriaType.TEXT,
                    value = "value"
                )
            )
        )

        @TestAsManager
        fun `createEntitlement RESTDOC`() {
            performPost(testUrl, request)
                .expectOk()
                .document(
                    "entitlements-create",
                    requestFields(createEntitlementFields()),
                    responseFields(entitlementFields()),
                )
            verify { service.createEntitlement(any(), eq(request)) }
        }

        @TestAsManager
        fun `createEntitlement should return 400 when failing `() {
            every { service.createEntitlement(any(), eq(request)) } throws BadRequestException("NOPE", "no")
            performPost(testUrl, request).expectBadRequest()
        }

        @TestAsReader
        fun `createEntitlement should not be allowed for READER`() {
            performPost(testUrl, request).expectForbidden()
            verify(exactly = 0) { service.createEntitlement(any(), eq(request)) }
        }
    }

    @Nested
    inner class updateEntitlement {

        val request = UpdateEntitlement(
            values = listOf(
                EntitlementValue(
                    criteriaId = newId(),
                    type = EntitlementCriteriaType.TEXT,
                    value = "value"
                )
            )
        )

        @TestAsManager
        fun `updateEntitlement RESTDOC`() {
            performPatch("$testUrl/${firstOne.id}", request)
                .expectOk()
                .document(
                    "entitlements-update",
                    requestFields(updateEntitlementFields()),
                    responseFields(entitlementFields()),
                )
            verify { service.updateEntitlement(any(), eq(firstOne.id), eq(request)) }
        }

        @TestAsManager
        fun `updateEntitlement should return 400 when failing `() {
            every { service.updateEntitlement(any(), eq(firstOne.id), eq(request)) } throws BadRequestException(
                "NOPE",
                "no"
            )
            performPatch("$testUrl/${firstOne.id}", request).expectBadRequest()
        }

        @TestAsReader
        fun `updateEntitlement should not be allowed for READER`() {
            performPatch("$testUrl/${firstOne.id}", request).expectForbidden()
            verify(exactly = 0) { service.updateEntitlement(any(), eq(firstOne.id), eq(request)) }
        }
    }

    @Nested
    inner class extendEntitlement {

        @TestAsManager
        fun `extendEntitlement RESTDOC`() {
            performPut("$testUrl/${firstOne.id}/extend")
                .expectOk()
                .document(
                    "entitlements-extend",
                    responseFields(entitlementFields()),
                )
            verify { service.extendEntitlement(any(), eq(firstOne.id)) }
        }

        @TestAsManager
        fun `extendEntitlement should return 400 when failing `() {
            every { service.extendEntitlement(any(), eq(firstOne.id)) } throws BadRequestException("NOPE", "no")
            performPut("$testUrl/${firstOne.id}/extend").expectBadRequest()
        }

        @TestAsReader
        fun `extendEntitlement should not be allowed for READER`() {
            performPut("$testUrl/${firstOne.id}/extend").expectForbidden()
            verify(exactly = 0) { service.extendEntitlement(any(), eq(firstOne.id)) }
        }
    }

    @Nested
    inner class updateQr {

        @TestAsManager
        fun `updateQr RESTDOC`() {
            performPut("$testUrl/${firstOne.id}/update-qr")
                .expectOk()
                .document(
                    "entitlements-update-qr",
                    responseFields(entitlementFields()),
                )
            verify { service.updateQrCode(any(), eq(firstOne.id)) }
        }

        @TestAsManager
        fun `updateQr should return 400 when failing `() {
            every { service.updateQrCode(any(), eq(firstOne.id)) } throws BadRequestException("NOPE", "no")
            performPut("$testUrl/${firstOne.id}/update-qr").expectBadRequest()
        }

        @TestAsReader
        fun `updateQr should not be allowed for READER`() {
            performPut("$testUrl/${firstOne.id}/update-qr").expectForbidden()
            verify(exactly = 0) { service.updateQrCode(any(), eq(firstOne.id)) }
        }
    }

    @Nested
    inner class viewQrPdf {

        @TestAsReader
        fun `viewQrPdf RESTDOC`() {
            performGet("$testUrl/${firstOne.id}/pdf").document("entitlements-view-qr")
            verify { service.viewQrPdf(any(), eq(firstOne.id)) }
        }

        @TestAsReader
        fun `viewQrPdf should return 404 when failing `() {
            every { service.viewQrPdf(any(), eq(firstOne.id)) } throws EntitlementsError.InvalidEntitlementNoQr("NOPE")
            performGet("$testUrl/${firstOne.id}/pdf").isNotFound()
        }
    }
}

fun createEntitlementFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "entitlementCauseId", STRING, "ObjectId"),
        field(prefix + "personId", STRING, "ObjectId of Person"),
        field(prefix + "values", JsonFieldType.ARRAY, "EntitlementValueDto"),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "values[]."))
    }
}

fun updateEntitlementFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "values", JsonFieldType.ARRAY, "EntitlementValueDto"),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "values[]."))
    }
}
