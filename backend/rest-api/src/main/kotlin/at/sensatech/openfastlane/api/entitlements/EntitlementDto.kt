package at.sensatech.openfastlane.api.entitlements

import at.sensatech.openfastlane.domain.models.AuditItem
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementValue
import java.time.ZonedDateTime

data class EntitlementDto(
    val id: String,
    val campaignId: String,
    val entitlementCauseId: String,
    val personId: String,
    val values: List<EntitlementValueDto>,
    var confirmedAt: ZonedDateTime?,
    var expiresAt: ZonedDateTime?,
    var createdAt: ZonedDateTime,
    var updatedAt: ZonedDateTime,
    var audit: MutableList<AuditItem>,
)

internal fun Entitlement.toDto(): EntitlementDto = EntitlementDto(
    id = this.id,
    entitlementCauseId = this.entitlementCauseId,
    campaignId = this.campaignId,
    personId = this.personId,
    values = this.values.map(EntitlementValue::toDto),
    confirmedAt = this.confirmedAt,
    expiresAt = this.expiresAt,
    createdAt = this.createdAt,
    updatedAt = this.updatedAt,
    audit = this.audit,
)
