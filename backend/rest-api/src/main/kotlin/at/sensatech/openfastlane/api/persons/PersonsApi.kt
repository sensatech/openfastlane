package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.services.CreatePerson
import at.sensatech.openfastlane.domain.services.PersonsService
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.LocalDate

@RequiresReader
@RestController
@RequestMapping("/persons", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class PersonsApi(
    private val service: PersonsService,
) {

    @RequiresReader
    @GetMapping
    fun listPersons(
        @Parameter(hidden = true)
        user: OflUser,
    ): List<PersonDto> {
        return service.listPersons(user).map(Person::toDto)
    }

    @RequiresReader
    @GetMapping("/{id}")
    fun getPerson(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): PersonDto {
        return service.getPerson(user, id)?.toDto() ?: throw NotFoundException(
            "PERSON_NOT_FOUND",
            "Person with id $id not found"
        )
    }

    @RequiresReader
    @GetMapping("/{id}/similar")
    fun getPersonSimilar(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<PersonDto> {
        val person = service.getPerson(user, id) ?: throw NotFoundException(
            "PERSON_NOT_FOUND",
            "Person with id $id not found"
        )
        return service.getPersonSimilars(user, person.id).map(Person::toDto)
    }

    @RequiresManager
    @PostMapping
    fun createPerson(
        @RequestParam(value = "strictMode", defaultValue = "false", required = false)
        strictMode: Boolean = false,

        @RequestBody
        request: CreatePerson,

        @Parameter(hidden = true)
        user: OflUser,
    ): PersonDto {
        return service.createPerson(user, request, strictMode).toDto()
    }

    @RequiresReader
    @GetMapping("/findSimilarPersons")
    fun findSimilarPersons(
        @RequestParam(value = "firstName")
        firstName: String,

        @RequestParam(value = "lastName")
        lastName: String,

        @RequestParam(value = "dateOfBirth", required = false)
        dateOfBirthString: String?,

        @Parameter(hidden = true)
        user: OflUser,
    ): Any {
        val dateOfBirth = LocalDate.parse(dateOfBirthString)
        return service.findSimilarPersons(user, firstName, lastName, dateOfBirth).map(Person::toDto).ifEmpty {
            ResponseEntity<Void>(HttpStatus.NO_CONTENT)
        }
    }

    @RequiresReader
    @GetMapping("/findWithSimilarAddress")
    fun findWithSimilarAddress(
        @RequestParam(value = "addressId", required = false)
        addressId: String?,

        @RequestParam(value = "streetNameNumber", required = false)
        streetNameNumber: String?,

        @RequestParam(value = "addressSuffix", required = false)
        addressSuffix: String?,

        @Parameter(hidden = true)
        user: OflUser
    ): Any {
        if (addressId == null && streetNameNumber == null) {
            return ResponseEntity<Void>(HttpStatus.BAD_REQUEST)
        }
        return service.findWithSimilarAddress(user, addressId, streetNameNumber, addressSuffix).map(Person::toDto)
            .ifEmpty {
                ResponseEntity<Void>(HttpStatus.NO_CONTENT)
            }
    }
}
