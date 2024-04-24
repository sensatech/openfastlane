package at.sensatech.openfastlane.api.consumptions

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresManager
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.slf4j.LoggerFactory
import org.springframework.core.io.InputStreamResource
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.io.File
import java.io.FileInputStream
import java.time.ZonedDateTime

@RequiresReader
@RestController
@RequestMapping("/consumptions", produces = [ApiVersions.CONTENT_DEFAULT, ApiVersions.CONTENT_V1])
class ConsumptionsApi(
    private val service: ConsumptionsService,
) {

    @RequiresReader
    @GetMapping("/find")
    fun findConsumptions(
        @Parameter(hidden = true)
        user: OflUser,

        @RequestParam(required = false)
        campaignId: String?,

        @RequestParam(required = false)
        causeId: String?,

        @RequestParam(required = false)
        personId: String?,

        @RequestParam(name = "from", required = false)
        fromString: String?,

        @RequestParam(name = "to", required = false)
        toString: String?,
    ): List<ConsumptionDto> {
        val from = dateTimeOrNull(fromString)
        val to = dateTimeOrNull(toString)
        val consumption = service.findConsumptions(
            user,
            campaignId = campaignId,
            causeId = causeId,
            personId = personId,
            from = from,
            to = to
        )
        return consumption.map(Consumption::toDto)
    }

    @RequiresManager
    @GetMapping("/export", produces = [MEDIA_TYPE_XLSX])
    fun exportConsumptions(
        @Parameter(hidden = true)
        user: OflUser,

        @RequestParam(required = false)
        campaignId: String?,

        @RequestParam(required = false)
        causeId: String?,

        @RequestParam(name = "from", required = false)
        fromString: String?,

        @RequestParam(name = "to", required = false)
        toString: String?,
    ): ResponseEntity<InputStreamResource> {

        val from = dateTimeOrNull(fromString)
        val to = dateTimeOrNull(toString)
        val fileResult = service.exportConsumptions(
            user,
            campaignId = campaignId,
            causeId = causeId,
            from = from,
            to = to
        )
            ?: return ResponseEntity.badRequest().build()

        val file = fileResult.file ?: File(fileResult.name)
        val resource = InputStreamResource(FileInputStream(file))
        return ResponseEntity.ok()
            .contentLength(file.length())
            .header("Content-Disposition", "attachment; filename=${fileResult.name}")
            .contentType(MediaType.valueOf(MEDIA_TYPE_XLSX))
            .body(resource)
    }

    fun dateTimeOrNull(value: String?): ZonedDateTime? {
        try {
            return value?.let { ZonedDateTime.parse(it) }
        } catch (e: Exception) {
            log.warn("Failed to parse date: $value")
            return null
        }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
        const val MEDIA_TYPE_XLSX = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
}
