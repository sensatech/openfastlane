package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

sealed class MailError(errorName: String, message: String) : ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class SendingFailedInvalidRecipient(info: String) :
        MailError("INVALID_MAIL_RECIPIENT", "Not a valid recipient: $info")

    @ResponseStatus(code = HttpStatus.NOT_FOUND)
    class SendingFailedMissingRecipient(info: String) :
        MailError("NO_MAIL_RECIPIENT", "Not a valid recipient: $info")

    @ResponseStatus(code = HttpStatus.NOT_IMPLEMENTED)
    class SendingFailedMisconfiguredServer(info: String, message: String) :
        MailError("MAILING_MISCONFIGURED", "Bad server configuration for mailing: $info $message")

    @ResponseStatus(code = HttpStatus.SERVICE_UNAVAILABLE)
    class SendingFailedServerError(info: String, message: String?) :
        MailError("MAILING_FAILURE", "Server configuration for mailing failed currently: $info $message")
}
