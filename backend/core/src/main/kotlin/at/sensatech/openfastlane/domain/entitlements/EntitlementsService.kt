package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.security.OflUser

interface EntitlementsService {

    fun listAllEntitlements(user: OflUser): List<Entitlement>
    fun getEntitlement(user: OflUser, id: String): Entitlement?

    fun getPersonEntitlements(user: OflUser, personId: String): List<Entitlement>
    fun createEntitlement(user: OflUser, request: CreateEntitlement): Entitlement

    /**
     * Causes
     */

    fun listAllEntitlementCauses(user: OflUser): List<EntitlementCause>
    fun getEntitlementCause(user: OflUser, id: String): EntitlementCause?
}
