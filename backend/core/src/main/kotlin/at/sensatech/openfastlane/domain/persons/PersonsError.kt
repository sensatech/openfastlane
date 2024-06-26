package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import at.sensatech.openfastlane.domain.services.ServiceError
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ExcludeFromJacocoGeneratedReport
sealed class PersonsError(errorName: String, message: String) :
    ServiceError(errorName, message, null) {

    @ResponseStatus(code = HttpStatus.NOT_FOUND)
    class NotFoundException(id: String) :
        PersonsError(
            "PERSON_NOT_FOUND",
            "Person with id $id not found",
        )

    @ResponseStatus(code = HttpStatus.BAD_REQUEST)
    class StrictModeDuplicatesCreation(count: Int) :
        PersonsError(
            "STRICT_MODE_DUPLICATES_DURING_CREATION",
            "Too many similar persons ($count) found during creation while strict mode was used",
        )
}
