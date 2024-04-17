package at.sensatech.openfastlane.api.persons

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.api.entitlements.EntitlementDto
import at.sensatech.openfastlane.api.entitlements.toDto
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.models.AuditItem
import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.persons.CreatePerson
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.persons.PersonsService
import at.sensatech.openfastlane.domain.persons.UpdatePerson
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
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
    private val entitlementsService: EntitlementsService,
) {

    @RequiresReader
    @GetMapping
    fun listPersons(
        @RequestParam(value = "withEntitlements", defaultValue = "false", required = false)
        withEntitlements: Boolean = false,

        @RequestParam(value = "withLastConsumptions", defaultValue = "false", required = false)
        withLastConsumptions: Boolean = false,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<PersonDto> {
        return service.listPersons(user, withEntitlements = withEntitlements).map {
            it.toDto(
                withEntitlements = withEntitlements,
                withLastConsumptions = withLastConsumptions
            )
        }
    }

    @RequiresReader
    @GetMapping("/{id}")
    fun getPerson(
        @PathVariable(value = "id")
        id: String,

        @RequestParam(value = "withEntitlements", defaultValue = "false", required = false)
        withEntitlements: Boolean = false,

        @RequestParam(value = "withLastConsumptions", defaultValue = "false", required = false)
        withLastConsumptions: Boolean = false,

        @Parameter(hidden = true)
        user: OflUser,
    ): PersonDto {
        return service.getPerson(user, id, withEntitlements = withEntitlements)?.toDto(
            withEntitlements = withEntitlements,
            withLastConsumptions = withLastConsumptions
        ) ?: throw PersonsError.NotFoundException(id)
    }

    @RequiresReader
    @GetMapping("/{id}/history")
    fun getPersonAudit(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<AuditItem> {
        return service.getPerson(user, id, withEntitlements = false)?.audit
            ?: throw PersonsError.NotFoundException(id)
    }

    @RequiresReader
    @GetMapping("/{id}/entitlements")
    fun getPersonEntitlements(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<EntitlementDto> {
        val person = service.getPerson(user, id, withEntitlements = false) ?: throw PersonsError.NotFoundException(id)
        return entitlementsService.getPersonEntitlements(user, person.id).map { it.toDto() }
    }

    @RequiresReader
    @GetMapping("/{id}/similar")
    fun getPersonSimilar(
        @PathVariable(value = "id")
        id: String,

        @RequestParam(value = "withEntitlements", defaultValue = "false", required = false)
        withEntitlements: Boolean = false,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<PersonDto> {
        val person =
            service.getPerson(user, id, withEntitlements = withEntitlements) ?: throw PersonsError.NotFoundException(
                id
            )
        return service.getPersonSimilars(user, person.id, withEntitlements = false).map(Person::toDto)
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

    @RequiresManager
    @PatchMapping("/{id}")
    fun updatePerson(
        @PathVariable(value = "id")
        id: String,

        @RequestBody
        request: UpdatePerson,

        @Parameter(hidden = true)
        user: OflUser,
    ): PersonDto {
        return service.updatePerson(user, id, request).toDto()
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

        @RequestParam(value = "withEntitlements", defaultValue = "false", required = false)
        withEntitlements: Boolean = false,

        @RequestParam(value = "withLastConsumptions", defaultValue = "false", required = false)
        withLastConsumptions: Boolean = false,

        @Parameter(hidden = true)
        user: OflUser,
    ): Any {
        val dateOfBirth = LocalDate.parse(dateOfBirthString)
        return service.findSimilarPersons(user, firstName, lastName, dateOfBirth, withEntitlements = withEntitlements)
            .map {
                it.toDto(
                    withEntitlements = withEntitlements,
                    withLastConsumptions = withLastConsumptions
                )
            }.ifEmpty {
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

        @RequestParam(value = "withEntitlements", defaultValue = "false", required = false)
        withEntitlements: Boolean = false,

        @RequestParam(value = "withLastConsumptions", defaultValue = "false", required = false)
        withLastConsumptions: Boolean = false,

        @Parameter(hidden = true)
        user: OflUser
    ): Any {
        if (addressId == null && streetNameNumber == null) {
            return ResponseEntity<Void>(HttpStatus.BAD_REQUEST)
        }
        return service.findWithSimilarAddress(
            user,
            addressId,
            streetNameNumber,
            addressSuffix,
            withEntitlements = withEntitlements
        )
            .map {
                it.toDto(
                    withEntitlements = withEntitlements,
                    withLastConsumptions = withLastConsumptions
                )
            }.ifEmpty {
                ResponseEntity<Void>(HttpStatus.NO_CONTENT)
            }
    }
}
