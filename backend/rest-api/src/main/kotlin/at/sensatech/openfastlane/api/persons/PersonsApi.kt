package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.services.PersonsService
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


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
}


