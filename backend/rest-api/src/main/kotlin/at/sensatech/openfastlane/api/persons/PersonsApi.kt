package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.services.PersonsService
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*
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
    @GetMapping("/findSimilarPersons")
    fun findSimilarPersons(
        @Parameter(hidden = true)
        user: OflUser,

        @RequestParam(value = "firstName")
        firstName: String,

        @RequestParam(value = "lastName")
        lastName: String,

        @RequestParam(value = "birthDay", required = false)
        birthDay: String?,
    ): Any {
        val birthDate = LocalDate.parse(birthDay)
        return service.findSimilarPersons(user, firstName, lastName, birthDate).map(Person::toDto).ifEmpty {
            ResponseEntity<Void>(HttpStatus.NO_CONTENT)
        }
    }

    @RequiresReader
    @GetMapping("/findWithSimilarAddress")
    fun findWithSimilarAddress(
        @Parameter(hidden = true)
        user: OflUser,

        @RequestParam(value = "addressId", required = false)
        addressId: String?,

        @RequestParam(value = "streetNameNumber", required = false)
        streetNameNumber: String?,

        @RequestParam(value = "addressSuffix", required = false)
        addressSuffix: String?,

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
