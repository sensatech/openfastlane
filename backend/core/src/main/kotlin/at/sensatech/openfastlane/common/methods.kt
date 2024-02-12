package at.sensatech.openfastlane.common

import org.bson.types.ObjectId
import java.time.LocalDate

fun newId() = ObjectId.get().toString()

fun String.toLocalDateOrNull(): LocalDate? = try {
    LocalDate.parse(this)
} catch (e: Exception) {
    null
}

@Retention(AnnotationRetention.RUNTIME)
annotation class ExcludeFromJacocoGeneratedReport
