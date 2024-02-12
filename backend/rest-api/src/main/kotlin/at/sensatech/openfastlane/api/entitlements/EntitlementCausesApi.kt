package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RequiresReader
@RestController
@RequestMapping("/entitlement-causes", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class EntitlementCausesApi(
    private val service: EntitlementsService,
) {

    @RequiresReader
    @GetMapping
    fun listAllEntitlementCauses(
        @Parameter(hidden = true)
        user: OflUser,
    ): List<EntitlementCauseDto> {
        return service.listAllEntitlementCauses(user).map(EntitlementCause::toDto)
    }

    @RequiresReader
    @GetMapping("/{id}")
    fun getEntitlementCause(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementCauseDto {
        return service.getEntitlementCause(user, id)?.toDto() ?: throw notFoundException(id)
    }

    private fun notFoundException(id: String) = NotFoundException(
        "ENTITLEMENT_CAUSE_NOT_FOUND",
        "Entitlement cause with id $id not found"
    )
}
