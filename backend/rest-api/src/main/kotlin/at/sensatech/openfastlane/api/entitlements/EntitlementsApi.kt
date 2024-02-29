package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.entitlements.UpdateEntitlement
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
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

    @RequiresReader
    @GetMapping("/{id}")
    fun getEntitlement(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.getEntitlement(user, id)?.toDto()
            ?: throw EntitlementsError.NoEntitlementFound(id)
    }

    @RequiresManager
    @PatchMapping("/{id}")
    fun updateEntitlement(
        @PathVariable(value = "id")
        id: String,

        @RequestBody
        request: UpdateEntitlement,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.updateEntitlement(user, id, request).toDto()
    }

    @RequiresManager
    @PutMapping("/{id}/extend")
    fun extendEntitlement(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.extendEntitlement(user, id).toDto()
    }
}
