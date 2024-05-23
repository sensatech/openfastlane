package at.sensatech.openfastlane.common

import org.bson.types.ObjectId
import java.time.LocalDate
import java.time.format.DateTimeFormatter

fun newId() = ObjectId.get().toString()

val deDateFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("d.M.yyyy")

fun String.toLocalDateOrNull(): LocalDate? = try {
    LocalDate.parse(this)
} catch (e: Exception) {
    try {
        LocalDate.parse(this, deDateFormatter)
    } catch (e: Exception) {
        null
    }
}

@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY, AnnotationTarget.FILE)
annotation class ExcludeFromJacocoGeneratedReport
