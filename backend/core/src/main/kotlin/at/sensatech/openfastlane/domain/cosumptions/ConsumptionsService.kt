package at.sensatech.openfastlane.domain.cosumptions

import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.security.OflUser
import java.time.ZonedDateTime

interface ConsumptionsService {

    fun getConsumption(user: OflUser, id: String): Consumption?

    fun findConsumptions(
        user: OflUser,
        campaignId: String? = null,
        causeId: String? = null,
        personId: String? = null,
        from: ZonedDateTime? = null,
        to: ZonedDateTime? = null,
    ): List<Consumption>

    fun checkConsumptionPossibility(
        user: OflUser,
        personId: String,
        campaignId: String,
    ): ConsumptionPossibility?

    fun performConsumption(
        user: OflUser,
        personId: String,
        causeId: String,
    ): Consumption
}
