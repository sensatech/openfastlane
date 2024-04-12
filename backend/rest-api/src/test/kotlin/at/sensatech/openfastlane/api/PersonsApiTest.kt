package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.persons.PersonDto
import at.sensatech.openfastlane.api.persons.PersonsApi
import at.sensatech.openfastlane.api.persons.toDto
import at.sensatech.openfastlane.api.testcommons.docs
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.persons.CreatePerson
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.persons.PersonsService
import at.sensatech.openfastlane.domain.persons.UpdatePerson
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType.OBJECT
import org.springframework.restdocs.payload.JsonFieldType.STRING
import org.springframework.restdocs.payload.PayloadDocumentation.requestFields
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
import org.springframework.restdocs.request.RequestDocumentation.parameterWithName
import org.springframework.restdocs.request.RequestDocumentation.queryParameters
import org.springframework.test.context.ContextConfiguration

@WebMvcTest(controllers = [PersonsApi::class])
@ContextConfiguration(classes = [PersonsApi::class])
internal class PersonsApiTest : AbstractRestApiUnitTest() {

    private val testUrl = "/persons"

    @MockkBean
    private lateinit var service: PersonsService

    @MockkBean
    private lateinit var entitlementsService: EntitlementsService

    @BeforeEach
    fun beforeEach() {
        every { service.listPersons(any()) } returns persons
        every { service.findSimilarPersons(any(), any(), any(), any()) } returns persons
        every { service.findWithSimilarAddress(any(), any(), any(), any()) } returns persons
        every { service.getPerson(any(), any()) } returns null
        every { service.getPerson(any(), eq(firstPerson.id)) } returns firstPerson
        every { service.getPersonSimilars(any(), eq(firstPerson.id)) } returns persons
        every { service.createPerson(any(), any(), any()) } returns firstPerson
        every { service.updatePerson(any(), any(), any()) } returns firstPerson
        every {
            entitlementsService.getPersonEntitlements(any(), eq(firstPerson.id))
        } returns entitlements.filter { it.personId == firstPerson.id }
    }

    @Nested
    inner class listPersons {
        @TestAsReader
        fun `listPersons RESTDOC`() {
            performGet("$testUrl?withEntitlements=false&withLastConsumptions=false")
                .expectOk()
                .document(
                    "persons-list",
                    responseFields(personsFields("[].")),
                    queryParameters(
                        parameterWithName("withEntitlements").description("includes nested (default false)").optional(),
                        parameterWithName("withLastConsumptions").description("includes nested (default false)")
                            .optional()
                    )
                )
            verify { service.listPersons(any()) }
        }

        @TestAsReader
        fun `listPersons returns plain`() {
            val url = "$testUrl"
            val list: List<PersonDto> = performGet(url).returnsList(PersonDto::class.java)
            val result = list.first()
            assertThat(result).isNotNull
            assertThat(result.entitlements).isNull()
            assertThat(result.lastConsumptions).isNull()
        }

        @TestAsReader
        fun `listPersons returns with Entitlements when requested with withEntitlements=true`() {
            val url = "$testUrl?withEntitlements=true"
            val list: List<PersonDto> = performGet(url).document(
                "persons-get-withEntitlements",
                responseFields(personsFields("[].", withEntitlements = true)),
            ).returnsList(PersonDto::class.java)
            val result = list.first()
            assertThat(result).isNotNull
            assertThat(result.entitlements).isNotNull
        }

        @TestAsReader
        fun `listPersons returns with last Consumptions when requested with withLastConsumptions=true`() {
            val url = "$testUrl?withLastConsumptions=true"
            val list: List<PersonDto> = performGet(url).document(
                "persons-get-withLastConsumptions",
                responseFields(personsFields("[].", withLastConsumptions = true)),
            ).returnsList(PersonDto::class.java)
            val result = list.first()
            assertThat(result).isNotNull
            assertThat(result.lastConsumptions).isNotNull
        }
    }

    @Nested
    inner class getPerson {

        @TestAsReader
        fun `getPerson RESTDOC`() {
            val url = "$testUrl/${firstPerson.id}?withEntitlements=false&withLastConsumptions=false"
            performGet(url)
                .expectOk()
                .document(
                    "persons-get",
                    responseFields(personsFields()),
                    queryParameters(
                        parameterWithName("withEntitlements").description("includes nested (default false)").optional(),
                        parameterWithName("withLastConsumptions").description("includes nested (default false)")
                            .optional()
                    )
                )
            verify { service.getPerson(any(), eq(firstPerson.id)) }
        }

        @TestAsReader
        fun `getPerson returns plain`() {
            val url = "$testUrl/${firstPerson.id}"
            val result: PersonDto = performGet(url).returns()
            assertThat(result).isNotNull
            assertThat(result.entitlements).isNull()
            assertThat(result.lastConsumptions).isNull()
        }

        @TestAsReader
        fun `getPerson returns with Entitlements when requested with withEntitlements=true`() {
            val url = "$testUrl/${firstPerson.id}?withEntitlements=true"
            val result: PersonDto = performGet(url).document(
                "persons-get-withEntitlements",
                responseFields(personsFields(withEntitlements = true)),
            ).returns()
            assertThat(result).isNotNull
            assertThat(result.entitlements).isNotNull
        }

        @TestAsReader
        fun `getPerson returns with last Consumptions when requested with withLastConsumptions=true`() {
            val url = "$testUrl/${firstPerson.id}?withLastConsumptions=true"
            val result: PersonDto = performGet(url).document(
                "persons-get-withLastConsumptions",
                responseFields(personsFields(withLastConsumptions = true)),
            ).returns()
            assertThat(result).isNotNull
            assertThat(result.lastConsumptions).isNotNull
        }


    }

    @TestAsReader
    fun `getPersonEntitlements RESTDOC`() {
        val url = "$testUrl/${firstPerson.id}/entitlements"
        performGet(url)
            .expectOk()
            .document(
                "persons-entitlements",
                responseFields(entitlementFields("[]."))
            )
        verify { service.getPerson(any(), eq(firstPerson.id)) }
        verify { entitlementsService.getPersonEntitlements(any(), eq(firstPerson.id)) }
    }

    @Nested
    inner class getPersonSimilar {

        @TestAsReader
        fun `getPersonSimilar RESTDOC`() {
            val url = "$testUrl/${firstPerson.id}/similar"
            performGet(url)
                .expectOk()
                .document(
                    "persons-similar",
                    responseFields(personsFields("[]."))
                )
            verify { service.getPersonSimilars(any(), eq(firstPerson.id)) }
        }

        @TestAsReader
        fun `getPersonSimilar returns 404 if person is not found`() {

            val newId = newId()
            val url = "$testUrl/$newId/similar"
            performGet(url).isNotFound()
            verify { service.getPerson(any(), eq(newId)) }
        }

        @TestAsReader
        fun `getPersonSimilar returns empty list if person but no similars are found`() {
            every { service.getPersonSimilars(any(), eq(firstPerson.id)) } returns listOf()
            val url = "$testUrl/${firstPerson.id}/similar"
            performGet(url).expectOk()
            verify { service.getPerson(any(), eq(firstPerson.id)) }
            verify { service.getPersonSimilars(any(), eq(firstPerson.id)) }
        }
    }

    @Nested
    inner class createPerson {

        val request = CreatePerson(
            firstName = "John",
            lastName = "Doe",
            dateOfBirth = "2021-01-01",
            address = null,
            email = null,
            mobileNumber = null,
            gender = Gender.DIVERSE
        )

        @TestAsManager
        fun `createPerson RESTDOC`() {
            val url = "$testUrl?strictMode=false"

            performPost(url, request)
                .expectOk()
                .document(
                    "persons-create",
                    requestFields(createPersonFields()),
                    responseFields(personsFields()),
                    queryParameters(
                        parameterWithName("strictMode").description("if strictMode=true, fails when similar are found (default false)")
                            .optional()
                    )
                )
            verify { service.createPerson(any(), eq(request), eq(false)) }
        }

        @TestAsManager
        fun `createPerson should use strictMode = false as default`() {
            val url = testUrl

            performPost(url, request).expectOk()
            verify { service.createPerson(any(), eq(request), eq(false)) }
        }

        @TestAsManager
        fun `createPerson should fail with strictMode = true`() {
            val url = "$testUrl?strictMode=true"

            every {
                service.createPerson(
                    any(),
                    eq(request),
                    eq(true)
                )
            } throws PersonsError.StrictModeDuplicatesCreation(1)

            performPost(url, request).expectBadRequest()
        }

        @TestAsReader
        fun `createPerson should not be allowed for READER`() {
            val url = "$testUrl?strictMode=false"
            performPost(url, request).expectForbidden()
            verify(exactly = 0) { service.createPerson(any(), eq(request), eq(false)) }
        }
    }

    @Nested
    inner class updatePerson {

        val request = UpdatePerson(
            firstName = "John",
            lastName = "Doe",
            dateOfBirth = "2021-01-01",
            address = null,
            email = null,
            mobileNumber = null,
            gender = Gender.DIVERSE,
            comment = null
        )

        @TestAsManager
        fun `updatePerson RESTDOC`() {
            val url = "$testUrl/${firstPerson.id}"

            performPatch(url, request)
                .expectOk()
                .document(
                    "persons-update",
                    requestFields(createPersonFields()),
                    responseFields(personsFields()),
                )
            verify { service.updatePerson(any(), eq(firstPerson.id), eq(request)) }
        }

        @TestAsManager
        fun `updatePerson should fail NotFoundException and 404`() {
            val url = "$testUrl/${firstPerson.id}"

            every {
                service.updatePerson(
                    any(),
                    any(),
                    eq(request),
                )
            } throws PersonsError.NotFoundException("")

            performPatch(url, request).isNotFound()

            verify { service.updatePerson(any(), eq(firstPerson.id), eq(request)) }
        }

        @TestAsReader
        fun `updatePerson should not be allowed for READER`() {
            val url = "$testUrl/${firstPerson.id}"
            performPatch(url, request).expectForbidden()
            verify(exactly = 0) { service.updatePerson(any(), eq(firstPerson.id), eq(request)) }
        }
    }

    @TestAsReader
    fun `getPerson should return 404`() {
        val url = "$testUrl/${newId()}"
        this.performGet(url).isNotFound()
    }

    @TestAsReader
    fun `findSimilarPersons RESTDOC`() {
        val firstName = "John"
        val lastName = "Doe"
        val dateOfBirth = "2021-01-01"
        val url = "$testUrl/findSimilarPersons?firstName=$firstName&lastName=$lastName&dateOfBirth=$dateOfBirth"
        this.performGet(url)
            .expectOk()
            .document(
                "persons-findSimilarPersons",
                responseFields(personsFields("[].")),
                queryParameters(
                    parameterWithName("firstName").description("First name"),
                    parameterWithName("lastName").description("Last name"),
                    parameterWithName("dateOfBirth").description("dateOfBirth (optional)").optional()
                )
            )

        verify { service.findSimilarPersons(any(), eq(firstName), eq(lastName), any()) }
    }

    @TestAsReader
    fun `findSimilarPersons returns 204 for empty list`() {
        val firstName = "John"
        val lastName = "Doe"
        val dateOfBirth = "2021-01-01"
        val url = "$testUrl/findSimilarPersons?firstName=$firstName&lastName=$lastName&dateOfBirth=$dateOfBirth"

        every { service.findSimilarPersons(any(), eq(firstName), eq(lastName), any()) } returns listOf()
        this.performGet(url)
            .expectNoContent()
            .document("persons-findSimilarPersons-empty")
        verify { service.findSimilarPersons(any(), eq(firstName), eq(lastName), any()) }
    }

    @TestAsReader
    fun `findWithSimilarAddress RESTDOC`() {
        val addressId = "addressId"
        val streetNameNumber = "streetNameNumber"
        val addressSuffix = "addressSuffix"
        val url =
            "$testUrl/findWithSimilarAddress?addressId=$addressId&addressSuffix=$addressSuffix&streetNameNumber=$streetNameNumber"
        this.performGet(url)
            .expectOk()
            .document(
                "persons-findWithSimilarAddress",
                responseFields(personsFields("[].")),
                queryParameters(
                    parameterWithName("addressId").description("AddressId of Vienna GIS").optional(),
                    parameterWithName("streetNameNumber").description("Straße und Hausnummer").optional(),
                    parameterWithName("addressSuffix").description("Suffix of the address, usually door number")
                        .optional(),
                )
            )

        verify { service.findWithSimilarAddress(any(), eq(addressId), eq(streetNameNumber), eq(addressSuffix)) }
    }

    @TestAsReader
    fun `findWithSimilarAddress returns 204 for empty list`() {
        val addressId = "addressId"
        val streetNameNumber = "streetNameNumber"
        val addressSuffix = "addressSuffix"
        val url =
            "$testUrl/findWithSimilarAddress?addressId=$addressId&addressSuffix=$addressSuffix&streetNameNumber=$streetNameNumber"

        every {
            service.findWithSimilarAddress(
                any(),
                any(),
                any(),
                any(),
            )
        } returns listOf()
        this.performGet(url)
            .expectNoContent()
            .document("persons-findWithSimilarAddress-empty")
    }

    @TestAsReader
    fun `findWithSimilarAddress returns 404 when nothing was provided`() {
        val url = "$testUrl/findWithSimilarAddress"

        every {
            service.findWithSimilarAddress(
                any(),
                any(),
                any(),
                any(),
            )
        } returns listOf()
        this.performGet(url).expectBadRequest()
    }

    @TestAsReader
    fun `AddressDto should map Address`() {
        val address = firstPerson.address
        val dto = address!!.toDto()
        assertThat(address.streetNameNumber).isEqualTo(dto.streetNameNumber)
        assertThat(address.addressSuffix).isEqualTo(dto.addressSuffix)
        assertThat(address.postalCode).isEqualTo(dto.postalCode)
        assertThat(address.addressId).isEqualTo(dto.addressId)
        assertThat(address.gipNameId).isEqualTo(dto.gipNameId)
    }

    @TestAsReader
    fun `PersonDto should map Person`() {
        val dto = firstPerson.toDto()
        assertThat(firstPerson.id).isEqualTo(dto.id)
        assertThat(firstPerson.firstName).isEqualTo(dto.firstName)
        assertThat(firstPerson.lastName).isEqualTo(dto.lastName)
        assertThat(firstPerson.dateOfBirth).isEqualTo(dto.dateOfBirth)
        assertThat(firstPerson.gender).isEqualTo(dto.gender)
        assertThat(firstPerson.address!!.toDto()).isEqualTo(dto.address)
        assertThat(firstPerson.email).isEqualTo(dto.email)
        assertThat(firstPerson.mobileNumber).isEqualTo(dto.mobileNumber)
        assertThat(firstPerson.comment).isEqualTo(dto.comment)
        assertThat(firstPerson.similarPersonIds).isEqualTo(dto.similarPersonIds)
        assertThat(firstPerson.createdAt).isEqualTo(dto.createdAt)
        assertThat(firstPerson.updatedAt).isEqualTo(dto.updatedAt)
    }
}

fun createPersonFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "firstName", STRING, "String"),
        field(prefix + "lastName", STRING, "String"),
        field(prefix + "dateOfBirth", STRING, "LocalDate").optional(),
        field(prefix + "gender", STRING, "gender, one of ${Gender.entries.docs()}").optional(),
        field(prefix + "address", OBJECT, "address object (nullable)").optional(),
        field(prefix + "email", STRING, "email (nullable)").optional(),
        field(prefix + "mobileNumber", STRING, "mobileNumber (nullable)").optional(),
        field(prefix + "comment", STRING, "comment (nullable)").optional(),
    ).toMutableList().apply {
        addAll(addressFields(prefix + "address."))
    }
}
