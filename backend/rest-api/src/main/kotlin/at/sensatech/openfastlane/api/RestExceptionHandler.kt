package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.common.RestExceptionDto
import at.sensatech.openfastlane.domain.exceptions.BadRequestException
import at.sensatech.openfastlane.domain.exceptions.ConflictException
import at.sensatech.openfastlane.domain.exceptions.ForbiddenContentException
import at.sensatech.openfastlane.domain.exceptions.NotFoundException
import at.sensatech.openfastlane.domain.exceptions.RestException
import at.sensatech.openfastlane.domain.exceptions.UnauthorizedException
import at.sensatech.openfastlane.domain.exceptions.ValidationException
import at.sensatech.openfastlane.domain.services.ServiceError
import at.sensatech.openfastlane.tracking.ErrorEvent
import at.sensatech.openfastlane.tracking.TrackingService
import org.hibernate.exception.ConstraintViolationException
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.ResponseBody
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
@ControllerAdvice
class RestExceptionHandler {

    @Autowired
    var trackingService: TrackingService? = null

    private fun trackException(exception: Exception) {
        val event = ErrorEvent(
            eventCategory = "Exception",
            eventAction = exception.javaClass.simpleName,
            eventName = exception.message?.take(100) ?: exception.javaClass.simpleName,
            exception = exception,
        )
        trackingService?.track(event)
    }

    @ExceptionHandler(NotFoundException::class)
    fun handleNotFoundException(exception: NotFoundException): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(exception)
        log.warn("NOT_FOUND", exception)
        trackException(exception)
        return ResponseEntity(error, HttpStatus.NOT_FOUND)
    }

    @ExceptionHandler(UnauthorizedException::class)
    fun handleUnauthorizedException(exception: UnauthorizedException): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(exception)
        trackException(exception)
        log.warn("UNAUTHORIZED", exception)
        return ResponseEntity(error, HttpStatus.UNAUTHORIZED)
    }

    @ExceptionHandler(ConstraintViolationException::class)
    fun handleConstraintViolationException(exception: ConstraintViolationException): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(RestException("ConstraintViolationException", "already exists"))
        trackException(exception)
        log.warn("CONFLICT", exception)
        return ResponseEntity(error, HttpStatus.CONFLICT)
    }

    @ExceptionHandler(RestException::class)
    fun handleException(exception: RestException): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(exception)
        trackException(exception)
        log.warn("BAD_REQUEST RestException", exception)
        return ResponseEntity(error, HttpStatus.BAD_REQUEST)
    }

    @ExceptionHandler(ServiceError::class)
    fun handleException(exception: ServiceError): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(exception)
        trackException(exception)
        log.warn("BAD_REQUEST ServiceError", exception)
        return ResponseEntity(error, HttpStatus.BAD_REQUEST)
    }

    @ExceptionHandler(ValidationException::class)
    fun handleException(exception: ValidationException): ResponseEntity<RestExceptionDto> {
        val error = RestExceptionDto(exception)
        trackException(exception)
        log.warn("BAD_REQUEST ValidationException", exception)
        return ResponseEntity(error, HttpStatus.BAD_REQUEST)
    }

    @ExceptionHandler(BadRequestException::class)
    fun handleException(exception: BadRequestException): ResponseEntity<RestExceptionDto> {
        trackException(exception)
        return ResponseEntity(RestExceptionDto(exception), HttpStatus.BAD_REQUEST)
    }

    @ExceptionHandler(ConflictException::class)
    fun handleException(exception: ConflictException): ResponseEntity<RestExceptionDto> {
        trackException(exception)
        return ResponseEntity(RestExceptionDto(exception), HttpStatus.CONFLICT)
    }

    @ExceptionHandler(ForbiddenContentException::class)
    fun handleException(exception: ForbiddenContentException): ResponseEntity<RestExceptionDto> {
        trackException(exception)
        return ResponseEntity(RestExceptionDto(exception), HttpStatus.UNAVAILABLE_FOR_LEGAL_REASONS)
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ResponseBody
    fun validationError(exception: MethodArgumentNotValidException): ResponseEntity<RestExceptionDto> {
        trackException(exception)
        return ResponseEntity(
            RestExceptionDto("MethodArgumentNotValidException", exception.toString()),
            HttpStatus.BAD_REQUEST
        )
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
