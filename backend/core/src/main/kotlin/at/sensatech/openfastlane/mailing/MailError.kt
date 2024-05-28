package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

sealed class MailError(errorName: String, message: String) : ServiceError(errorName, message, null) {
    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class SendFailed(info: String) :
        MailError("MAIL_SEND_FAILED", "Mail could not be send or delivered: $info")
}
