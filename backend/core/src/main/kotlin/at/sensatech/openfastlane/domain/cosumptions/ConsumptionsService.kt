package at.sensatech.openfastlane.domain.cosumptions

import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.security.OflUser
import java.time.LocalDate

interface ConsumptionsService {

    // Service for Entitlements
    fun getConsumptionsOfEntitlement(user: OflUser, entitlementId: String): List<Consumption>

    fun getConsumption(user: OflUser, id: String): Consumption?

    fun checkConsumptionPossibility(user: OflUser, entitlementId: String): ConsumptionPossibility

    fun performConsumption(user: OflUser, entitlementId: String): Consumption

    // Service for Search and Export
    fun findConsumptions(
        user: OflUser,
        campaignId: String? = null,
        causeId: String? = null,
        personId: String? = null,
        from: LocalDate? = null,
        to: LocalDate? = null,
    ): List<Consumption>

    fun checkConsumptionPossibility(
        user: OflUser,
        personId: String,
        campaignId: String,
    ): ConsumptionPossibility?

    fun performConsumption(
        user: OflUser,
        personId: String,
        causeId: String,
    ): Consumption

    fun exportConsumptions(
        user: OflUser,
        campaignId: String? = null,
        causeId: String? = null,
        from: LocalDate? = null,
        to: LocalDate? = null
    ): FileResult?
}
