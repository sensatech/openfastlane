package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Consumption
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import java.time.ZonedDateTime

@Repository
interface ConsumptionRepository : MongoRepository<Consumption, String> {

    fun findByPersonIdAndEntitlementCauseIdAndConsumedAtIsBetween(
        personId: String,
        causeId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByPersonIdAndConsumedAtIsBetween(
        personId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByEntitlementCauseIdAndConsumedAtIsBetween(
        causeId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByConsumedAtIsBetween(
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByCampaignIdAndConsumedAtIsBetween(
        campaignId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>
}
