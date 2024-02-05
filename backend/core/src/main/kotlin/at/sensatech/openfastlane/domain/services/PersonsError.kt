package at.sensatech.openfastlane.domain.services

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

sealed class PersonsError(errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class StrictModeDuplicatesCreation(count: Int) :
        PersonsError(
            "STRICT_MODE_DUPLICATES_DURING_CREATION",
            "Too many similar persons ($count) found during creation while strict mode was used",
        )
}
