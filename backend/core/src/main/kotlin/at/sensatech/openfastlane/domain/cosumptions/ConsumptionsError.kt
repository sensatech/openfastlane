package at.sensatech.openfastlane.domain.cosumptions

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
sealed class ConsumptionsError(val value: ConsumptionPossibility, errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class NotPossibleError(value: ConsumptionPossibility) : ConsumptionsError(
        value,
        "CONSUMPTION_NOT_POSSIBLE",
        value.toString(),
    )

    @ResponseStatus(code = HttpStatus.CONFLICT)
    class AlreadyDoneError : ConsumptionsError(
        ConsumptionPossibility.CONSUMPTION_ALREADY_DONE,
        "CONSUMPTION_ALREADY_DONE",
        "Already happened in that Campaign's timeframe",
    )
}
