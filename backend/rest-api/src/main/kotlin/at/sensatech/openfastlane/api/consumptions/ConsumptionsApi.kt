package at.sensatech.openfastlane.api.consumptions

import at.sensatech.openfastlane.api.ApiVersions
import at.sensatech.openfastlane.api.RequiresReader
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsService
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.security.OflUser
import io.swagger.v3.oas.annotations.Parameter
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
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
    }
}
