package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.mocks.Mocks
import org.assertj.core.api.AbstractZonedDateTimeAssert
import java.time.ZonedDateTime

fun mockConsumptions(
    entitlements: List<Entitlement>,
    consumedAt: ZonedDateTime
): List<Consumption> {
    val consumptions = entitlements.map {
        Mocks.mockConsumption(
            personId = it.personId,
            entitlementCauseId = it.entitlementCauseId,
            campaignId = it.campaignId,
            consumedAt = consumedAt,
            entitlementData = it.values
        )
    }
    return consumptions
}

fun assertDateTime(actual: ZonedDateTime): ZonedDateTimeAssert {
    return ZonedDateTimeAssert(actual)
}

class ZonedDateTimeAssert(actual: ZonedDateTime) :
    AbstractZonedDateTimeAssert<ZonedDateTimeAssert>(actual, ZonedDateTimeAssert::class.java) {
    fun isApproximately(expected: ZonedDateTime): ZonedDateTimeAssert {
        return isBetween(expected.withNano(0).minusNanos(100), expected.plusNanos(1))
    }
}
