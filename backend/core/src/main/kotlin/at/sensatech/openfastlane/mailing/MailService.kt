package at.sensatech.openfastlane.mailing

import java.io.File

interface MailService {
    @Throws(MailError::class)
    fun sendMail(mailRequest: MailRequest, attachments: List<File>)
}
