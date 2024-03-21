package at.sensatech.openfastlane.domain.cosumptions

import java.time.ZonedDateTime

data class ConsumptionPossibility(
    val status: ConsumptionPossibilityType,
    val lastConsumptionAt: ZonedDateTime? = null,
)
