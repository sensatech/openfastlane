package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.api.RequiresScanner
import at.sensatech.openfastlane.api.consumptions.ConsumptionDto
import at.sensatech.openfastlane.api.consumptions.toDto
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsService
import at.sensatech.openfastlane.domain.entitlements.UpdateEntitlement
import at.sensatech.openfastlane.domain.models.AuditItem
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.springframework.core.io.InputStreamResource
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PatchMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.io.File
import java.io.FileInputStream

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

    @RequiresScanner
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
    @GetMapping("/{id}/pdf", produces = [MediaType.APPLICATION_PDF_VALUE])
    fun viewQr(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): ResponseEntity<InputStreamResource> {
        val pdf = service.viewQrPdf(user, id) ?: return ResponseEntity.badRequest().build()

        val file = pdf.file ?: File(pdf.name)
        val resource = InputStreamResource(FileInputStream(file))
        return ResponseEntity.ok()
            .contentLength(file.length())
            .header("Content-Disposition", "attachment; filename=${pdf.name}")
            .contentType(MediaType.APPLICATION_PDF)
            .body(resource)
    }

    @RequiresManager
    @PostMapping("/{id}/send-pdf")
    fun sendQr(
        @PathVariable(value = "id")
        id: String,

        @RequestBody(required = false)
        request: SendQrRequest? = null,

        @Parameter(hidden = true)
        user: OflUser,
    ): ResponseEntity<Any> {
        service.sendQrPdf(user, id, request?.recipient)
        return ResponseEntity.ok().build()
    }

    @RequiresReader
    @GetMapping("/{id}/history")
    fun getAudit(
        @PathVariable(value = "id")
        id: String,

        @Parameter(hidden = true)
        user: OflUser,
    ): List<AuditItem> {
        return service.getEntitlement(user, id)?.audit
            ?: throw EntitlementsError.NoEntitlementFound(id)
    }
}

data class SendQrRequest(
    val recipient: String,
)
