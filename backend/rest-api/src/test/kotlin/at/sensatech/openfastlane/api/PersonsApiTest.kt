package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.persons.PersonsApi
import at.sensatech.openfastlane.api.testcommons.docs
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.services.PersonsService
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType.OBJECT
import org.springframework.restdocs.payload.JsonFieldType.STRING
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

    @BeforeEach
    fun beforeEach() {
        every { service.listPersons(any()) } returns persons
        every { service.findNameDuplicates(any(), any(), any(), any()) } returns persons
        every { service.findAddressDuplicates(any(), any(), any()) } returns persons
        every { service.getPerson(any(), any()) } returns null
        every { service.getPerson(any(), eq(firstPerson.id)) } returns firstPerson
    }

    @TestAsReader
    fun `listPersons RESTDOC`() {
        this.performGet(testUrl)
            .expectOk()
            .document(
                "persons-list",
                responseFields(personsFields("[]."))
            )
        verify { service.listPersons(any()) }
    }

    @TestAsReader
    fun `getPerson RESTDOC`() {
        val url = "$testUrl/${firstPerson.id}"
        this.performGet(url)
            .expectOk()
            .document(
                "persons-get",
                responseFields(personsFields())
            )
        verify { service.getPerson(any(), eq(firstPerson.id)) }
    }

    @TestAsReader
    fun `getPerson should return 404`() {
        val url = "$testUrl/${newId()}"
        this.performGet(url).isNotFound()
    }

    @TestAsReader
    fun `findNameDuplicates RESTDOC`() {
        val firstName = "John"
        val lastName = "Doe"
        val birthDate = "2021-01-01"
        val url = "$testUrl/findNameDuplicates?firstName=$firstName&lastName=$lastName&birthDay=$birthDate"
        this.performGet(url)
            .expectOk()
            .document(
                "persons-findNameDuplicates",
                responseFields(personsFields("[].")),
                queryParameters(
                    parameterWithName("firstName").description("First name"),
                    parameterWithName("lastName").description("Last name"),
                    parameterWithName("birthDay").description("Birthday (optional)").optional()
                )
            )


        verify { service.findNameDuplicates(any(), eq(firstName), eq(lastName), any()) }
    }

    @TestAsReader
    fun `findNameDuplicates returns 204 for empty list`() {
        val firstName = "John"
        val lastName = "Doe"
        val birthDate = "2021-01-01"
        val url = "$testUrl/findNameDuplicates?firstName=$firstName&lastName=$lastName&birthDay=$birthDate"

        every { service.findNameDuplicates(any(), eq(firstName), eq(lastName), any()) } returns listOf()
        this.performGet(url)
            .expectNoContent()
            .document("persons-findNameDuplicates-empty")
        verify { service.findNameDuplicates(any(), eq(firstName), eq(lastName), any()) }
    }

    @TestAsReader
    fun `findAddressDuplicates RESTDOC`() {
        val addressId = "addressId"
        val addressSuffix = "addressSuffix"
        val url = "$testUrl/findAddressDuplicates?addressId=$addressId&addressSuffix=$addressSuffix"
        this.performGet(url)
            .expectOk()
            .document(
                "persons-findAddressDuplicates",
                responseFields(personsFields("[].")),
                queryParameters(
                    parameterWithName("addressId").description("AddressId of Vienna GIS"),
                    parameterWithName("addressSuffix").description("Suffix of the address, usually door number"),
                )
            )

        verify { service.findAddressDuplicates(any(), eq(addressId), eq(addressSuffix)) }
    }

    @TestAsReader
    fun `findAddressDuplicates returns 204 for empty list`() {
        val addressId = "addressId"
        val addressSuffix = "addressSuffix"
        val url = "$testUrl/findAddressDuplicates?addressId=$addressId&addressSuffix=$addressSuffix"

        every { service.findAddressDuplicates(any(), eq(addressId), eq(addressSuffix)) } returns listOf()
        this.performGet(url)
            .expectNoContent()
            .document("persons-findAddressDuplicates-empty")
    }
}

fun personsFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", STRING, "ObjectId"),
        field(prefix + "firstName", STRING, "String"),
        field(prefix + "lastName", STRING, "String"),
        field(prefix + "birthDate", STRING, "LocalDate").optional(),
        field(prefix + "gender", STRING, "gender, one of ${Gender.entries.docs()}").optional(),
        field(prefix + "address", OBJECT, "List of Departments (nullable)").optional(),
        field(prefix + "email", STRING, "List of Departments (nullable)").optional(),
        field(prefix + "mobileNumber", STRING, "List of Departments (nullable)").optional(),
        field(prefix + "comment", STRING, "List of Departments (nullable)").optional(),
        field(prefix + "createdAt", STRING, "createdAt"),
        field(prefix + "updatedAt", STRING, "updatedAt (nullable)").optional(),

        ).toMutableList().apply {
        addAll(addressFields(prefix + "address."))
    }
}

fun addressFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "streetNameNumber", STRING, "Streetname and number"),
        field(prefix + "addressSuffix", STRING, "Doornumber"),
        field(prefix + "postalCode", STRING, "PLZ"),
        field(prefix + "addressId", STRING, "Vienna GIS ID").optional(),
        field(prefix + "gipNameId", STRING, "Vienna GIS ID").optional(),
    )
}
