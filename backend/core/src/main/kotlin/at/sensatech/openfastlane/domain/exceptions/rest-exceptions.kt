package at.sensatech.openfastlane.domain.exceptions

import org.springframework.http.HttpStatus
import org.springframework.validation.FieldError
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(
    code = HttpStatus.BAD_REQUEST,
    reason = "Operation cannot be executed due to malformed input or invalid states."
)
open class RestException(
    val errorName: String,
    detailMessage: String,
    cause: Throwable? = null
) : RuntimeException(detailMessage, cause)

@ResponseStatus(
    code = HttpStatus.BAD_REQUEST,
    reason = "Operation cannot be executed due to malformed input or invalid states."
)
class ValidationException(message: String, val validationErrors: Array<FieldError?> = arrayOf()) :
    RestException("VALIDATION_ERROR", message) {
    constructor(validationErrors: Array<FieldError?>) : this(
        validationErrors.joinToString("\n") { it.toString() },
        validationErrors
    )
}

@ResponseStatus(code = HttpStatus.BAD_REQUEST, reason = "Cannot create entity due to a bad request")
class BadRequestException(errorName: String, detailMessage: String) : RestException(errorName, detailMessage)

@ResponseStatus(code = HttpStatus.UNAUTHORIZED, reason = "Unauthorized")
class UnauthorizedException(errorName: String, message: String? = null) : RestException(
    errorName,
    message
        ?: "Unauthorized"
)

@ResponseStatus(code = HttpStatus.NOT_FOUND, reason = "Entity not found")
open class NotFoundException(errorName: String, message: String) : RestException(errorName, message)

@ResponseStatus(code = HttpStatus.METHOD_NOT_ALLOWED, reason = "Method not allowed or supported")
class MethodNotAllowedException(errorName: String, message: String) : RestException(errorName, message)

@ResponseStatus(code = HttpStatus.UNAVAILABLE_FOR_LEGAL_REASONS, reason = "Reserved name forbidden to use")
class ForbiddenContentException(errorName: String, message: String) : RestException(errorName, message)

@ResponseStatus(code = HttpStatus.CONFLICT, reason = "Cannot create entity due to a duplicate conflict:")
class ConflictException(errorName: String, message: String) : RestException(errorName, message)

@ResponseStatus(code = HttpStatus.NOT_FOUND, reason = "User not found")
open class UserNotFoundException(message: String = "User is unknown and or not exist") :
    NotFoundException("USER_NOT_FOUND", message)

@ResponseStatus(code = HttpStatus.NOT_FOUND, reason = "Entity not found")
class DefaultNotFoundException(message: String = "Entity does not exist") :
    NotFoundException("NOT_FOUND", message)
