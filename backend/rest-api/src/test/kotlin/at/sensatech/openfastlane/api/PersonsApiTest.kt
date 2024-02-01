package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.persons.PersonsApi
import at.sensatech.openfastlane.api.testcommons.docs
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.services.PersonsService
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.mockk.verify
import org.junit.jupiter.api.BeforeEach
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType.*
import org.springframework.restdocs.payload.PayloadDocumentation.responseFields
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
        this.performGet(url)
            .expectNotFound()
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
