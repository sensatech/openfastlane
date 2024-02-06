package at.sensatech.openfastlane.common

import org.bson.types.ObjectId
import java.time.LocalDate

object ApplicationProfiles {
    const val TEST = "test"
    const val NOT_TEST = "!test"
    const val INTEGRATION_TEST = "integration-test"
    const val DOCKER = "docker"
}

fun newId() = ObjectId.get().toString()

fun String.toLocalDate(): LocalDate? = LocalDate.parse(this)

fun String.toLocalDateOrNull(): LocalDate? = try {
    LocalDate.parse(this)
} catch (e: Exception) {
    null
}
