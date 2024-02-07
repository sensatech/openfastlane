package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RequiresReader
@RestController
@RequestMapping("/entitlements", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class EntitlementsApi(
    private val service: EntitlementsService,
) {

    @RequiresReader
    @GetMapping
    fun listAllEntitlements(
        @Parameter(hidden = true)
        user: OflUser,
    ): List<EntitlementDto> {
        return service.listAllEntitlements(user).map(Entitlement::toDto)
    }

    @RequiresReader
    @GetMapping("/{id}")
    fun getEntitlement(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.getEntitlement(user, id)?.toDto() ?: throw notFoundException(id)
    }

    @RequiresManager
    @PostMapping
    fun createEntitlement(
        @RequestBody
        request: CreateEntitlement,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.createEntitlement(user, request).toDto()
    }

    private fun notFoundException(id: String) = NotFoundException(
        "ENTITLEMENT_NOT_FOUND",
        "Entitlement with id $id not found"
    )
}
