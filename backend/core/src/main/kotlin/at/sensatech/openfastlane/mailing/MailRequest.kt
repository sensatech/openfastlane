package at.sensatech.openfastlane.mailing

import java.util.Locale

data class MailRequest(
    val subject: String,
    val to: String,
    val templateFile: String,
    val templateMap: Map<String, Any>,
    val locale: Locale,
)

object MailRequests {

    fun sendQrPdf(
        to: String,
        locale: Locale,
        firstName: String,
        lastName: String,
    ): MailRequest {
        return MailRequest(
            subject = "[OpenFastLane] Ein neuer QR-Code wurde erstellt",
            to = to,
            templateFile = "send_qr_pdf.ftl",
            templateMap = mapOf(
                "firstName" to firstName,
                "lastName" to lastName,
            ),
            locale = locale,
        )
    }

}
