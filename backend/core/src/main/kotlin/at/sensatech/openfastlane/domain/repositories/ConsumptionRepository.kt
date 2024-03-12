package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Consumption
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository
import java.time.ZonedDateTime

@Repository
interface ConsumptionRepository : MongoRepository<Consumption, String> {

    fun findByPersonIdAndEntitlementCauseIdAndConsumedAtIsBetweenOrderByConsumedAt(
        personId: String,
        causeId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByPersonIdAndConsumedAtIsBetweenOrderByConsumedAt(
        personId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByEntitlementCauseIdAndConsumedAtIsBetweenOrderByConsumedAt(
        causeId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByConsumedAtIsBetweenOrderByConsumedAt(
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByCampaignIdAndConsumedAtIsBetweenOrderByConsumedAt(
        campaignId: String,
        from: ZonedDateTime,
        to: ZonedDateTime,
    ): List<Consumption>

    fun findByEntitlementCauseIdOrderByConsumedAt(entitlementCauseId: String): List<Consumption>
}
