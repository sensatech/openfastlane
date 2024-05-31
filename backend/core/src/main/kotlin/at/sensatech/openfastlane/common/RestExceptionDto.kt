package at.sensatech.openfastlane.common

import at.sensatech.openfastlane.domain.exceptions.RestException
import java.time.ZonedDateTime

data class RestExceptionDto(
    val errorName: String,
    val errorMessage: String,
    val time: ZonedDateTime = ZonedDateTime.now(),
) {
    constructor(
        restException: RestException,
        time: ZonedDateTime = ZonedDateTime.now(),
    ) : this(
        restException.errorName,
        restException.message.orEmpty(),
        time
    )
}
