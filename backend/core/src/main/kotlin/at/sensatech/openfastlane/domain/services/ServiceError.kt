package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.exceptions.RestException

open class ServiceError(
    errorName: String,
    message: String,
    cause: Throwable? = null,
) : RestException(errorName, message, cause)
