package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.api.consumptions.ConsumptionDto
import at.sensatech.openfastlane.api.consumptions.toDto
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.entitlements.UpdateEntitlement
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.http.MediaType
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.awt.image.BufferedImage

@RequiresReader
@RestController
@RequestMapping("/entitlements", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class EntitlementsApi(
    private val service: EntitlementsService,
    private val consumptionsService: ConsumptionsService,
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

    @RequiresReader
    @GetMapping("/{id}/consumptions")
    fun getEntitlementConsumptions(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<ConsumptionDto> {
        val entitlement = service.getEntitlement(user, id)
            ?: throw EntitlementsError.NoEntitlementFound(id)
        return consumptionsService.getConsumptionsOfEntitlement(user, entitlement.id).map { it.toDto() }
    }

    @RequiresReader
    @GetMapping("/{id}/consumptions/{consumptionId}")
    fun getEntitlementConsumption(
        @PathVariable(value = "id")
        id: String,

        @PathVariable(value = "consumptionId")
        consumptionId: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): ConsumptionDto {
        service.getEntitlement(user, id) ?: throw EntitlementsError.NoEntitlementFound(id)
        return consumptionsService.getConsumption(user, consumptionId)?.toDto()
            ?: throw EntitlementsError.NoConsumptionFound(id)
    }

    @RequiresReader
    @GetMapping("/{id}/can-consume")
    fun checkConsumptionPossibility(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): ConsumptionPossibility {
        return consumptionsService.checkConsumptionPossibility(user, id)
    }

    @RequiresManager
    @PostMapping("/{id}/consume")
    fun performConsumption(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): ConsumptionDto {
        service.getEntitlement(user, id) ?: throw EntitlementsError.NoEntitlementFound(id)
        return consumptionsService.performConsumption(user, id).toDto()
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

    @RequiresManager
    @PutMapping("/{id}/update-qr")
    fun updateQr(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): EntitlementDto {
        return service.updateQrCode(user, id).toDto()
    }

    @RequiresReader
    @GetMapping("/{id}/qr", produces = [MediaType.IMAGE_PNG_VALUE])
    fun viewQr(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): BufferedImage? {
        service.updateQrCode(user, id).toDto()
        val image = service.viewQr(user, id)
        return image ?: throw EntitlementsError.InvalidEntitlementNoQr(id)
    }
}
