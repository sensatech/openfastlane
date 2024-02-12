package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.entitlements.EntitlementCausesApi
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.mocks.Mocks
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.test.context.ContextConfiguration

@WebMvcTest(controllers = [EntitlementCausesApi::class])
@ContextConfiguration(classes = [EntitlementCausesApi::class])
internal class EntitlementCausesApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/entitlement-causes"

    @MockkBean
    private lateinit var service: EntitlementsService

    private val firstOne = Mocks.mockEntitlementCause()
    private val causes = listOf(firstOne, Mocks.mockEntitlementCause())

    @BeforeEach
    fun beforeEach() {
        every { service.listAllEntitlementCauses(any()) } returns causes
        every { service.getEntitlementCause(any(), any()) } returns null
        every { service.getEntitlementCause(any(), eq(firstOne.id)) } returns firstOne
    }

    @TestAsReader
    fun `listAllEntitlementCauses RESTDOC`() {
        this.performGet(testUrl)
            .expectOk()
            .document(
                "entitlement-causes-list",
                responseFields(entitlementCauseFields("[]."))
            )
        verify { service.listAllEntitlementCauses(any()) }
    }

    @TestAsReader
    fun `getEntitlementCause RESTDOC`() {
        val url = "$testUrl/${firstOne.id}"
        this.performGet(url)
            .expectOk()
            .document(
                "entitlement-causes-get",
                responseFields(entitlementCauseFields())
            )
        verify { service.getEntitlementCause(any(), eq(firstOne.id)) }
    }

    @TestAsReader
    fun `getEntitlementCause should return 404`() {
        val url = "$testUrl/${newId()}"
        this.performGet(url).isNotFound()
    }
}
