package at.sensatech.openfastlane.domain

import org.assertj.core.api.AbstractZonedDateTimeAssert
import java.time.ZonedDateTime

fun <SELF : AbstractZonedDateTimeAssert<SELF>> AbstractZonedDateTimeAssert<SELF>.isApproximately(now: ZonedDateTime) {
    isBetween(now.withNano(0).minusNanos(100), now.plusNanos(1))
}

fun <SELF : AbstractZonedDateTimeAssert<SELF>> AbstractZonedDateTimeAssert<SELF>.isApproximatelyNow() {
    val now = ZonedDateTime.now()
    isBetween(now.withNano(0).minusNanos(1000), now.plusNanos(100))
}

fun assertDateTime(actual: ZonedDateTime): ZonedDateTimeAssert {
    return ZonedDateTimeAssert(actual)
}

class ZonedDateTimeAssert(actual: ZonedDateTime) :
    AbstractZonedDateTimeAssert<ZonedDateTimeAssert>(actual, ZonedDateTimeAssert::class.java) {
    fun isApproximately(expected: ZonedDateTime): ZonedDateTimeAssert {
        return isBetween(expected.withNano(0).minusNanos(100), expected.plusNanos(1))
    }

    fun isApproximatelyNow(): ZonedDateTimeAssert {
        return isApproximately(ZonedDateTime.now())
    }
}
