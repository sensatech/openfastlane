package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.entitlements.EntitlementsApi
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.entitlements.UpdateEntitlement
import at.sensatech.openfastlane.domain.exceptions.BadRequestException
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType
import org.springframework.restdocs.payload.JsonFieldType.STRING
import org.springframework.restdocs.payload.PayloadDocumentation.requestFields
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.test.context.ContextConfiguration

@WebMvcTest(controllers = [EntitlementsApi::class])
@ContextConfiguration(classes = [EntitlementsApi::class])
internal class EntitlementsApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/entitlements"

    @MockkBean
    private lateinit var service: EntitlementsService

    private val firstOne = entitlements.first()

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
    inner class createEntitlement {

        val request = CreateEntitlement(
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
