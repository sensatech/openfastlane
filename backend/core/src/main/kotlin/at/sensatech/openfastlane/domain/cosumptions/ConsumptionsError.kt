package at.sensatech.openfastlane.domain.cosumptions

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
sealed class ConsumptionsError(val state: ConsumptionPossibilityType, errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class NotPossibleError(state: ConsumptionPossibilityType) : ConsumptionsError(
        state,
        "CONSUMPTION_NOT_POSSIBLE",
        state.toString(),
    )

    @ResponseStatus(code = HttpStatus.CONFLICT)
    class AlreadyDoneError : ConsumptionsError(
        ConsumptionPossibilityType.CONSUMPTION_ALREADY_DONE,
        "CONSUMPTION_ALREADY_DONE",
        "Already happened in that Campaign's timeframe",
    )
}
