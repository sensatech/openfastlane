package at.sensatech.openfastlane.documents

import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.Person

interface PdfGenerator {
    fun createPersonEntitlementQrPdf(
        pdfInfo: PdfInfo,
        person: Person,
        entitlement: Entitlement,
        qrValue: String,
        campaignName: String? = null,
        entitlementName: String? = null,
    ): PdfResult?
}
