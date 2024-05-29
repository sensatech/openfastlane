package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.documents.FileResult
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.security.OflUser

interface EntitlementsService {

    fun listAllEntitlements(user: OflUser): List<Entitlement>

    fun getEntitlement(user: OflUser, id: String): Entitlement?

    fun getPersonEntitlements(user: OflUser, personId: String): List<Entitlement>

    fun createEntitlement(user: OflUser, request: CreateEntitlement): Entitlement

    fun updateEntitlement(user: OflUser, id: String, request: UpdateEntitlement): Entitlement

    fun extendEntitlement(user: OflUser, id: String): Entitlement

    fun viewQrPdf(user: OflUser, id: String): FileResult?

    fun sendQrPdf(user: OflUser, id: String, mailRecipient: String?)
}
