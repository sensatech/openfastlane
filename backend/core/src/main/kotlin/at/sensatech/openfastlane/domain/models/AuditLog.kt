package at.sensatech.openfastlane.domain.models

import at.sensatech.openfastlane.security.OflUser
import java.time.ZonedDateTime

data class AuditItem(
    val user: String,
    val action: String,
    val message: String,
    val dateTime: ZonedDateTime
)

interface Auditable

fun MutableList<AuditItem>.logAudit(user: String, action: String, message: String) {
    add(AuditItem(user, action, message, ZonedDateTime.now()))
}

fun MutableList<AuditItem>.logAudit(user: OflUser, action: String, message: String) {
    logAudit(user.username, action, message)
}
