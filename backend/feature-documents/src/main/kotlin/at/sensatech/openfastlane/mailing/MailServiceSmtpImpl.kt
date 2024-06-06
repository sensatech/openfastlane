package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.config.OflMailSenderConfiguration
import freemarker.template.Template
import jakarta.mail.MessagingException
import org.slf4j.LoggerFactory
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.mail.javamail.MimeMessageHelper
import org.springframework.ui.freemarker.FreeMarkerTemplateUtils
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer
import java.io.File
import java.lang.System
import java.util.Locale

class MailServiceSmtpImpl(
    private val mailSender: JavaMailSender,
    private val freemarkerConfigurer: FreeMarkerConfigurer,
    senderConfiguration: OflMailSenderConfiguration,
) : MailService {

    private val senderFrom by lazy { senderConfiguration.senderFrom }
    val senderName by lazy { senderConfiguration.senderName }

    @Throws(MailError::class)
    override fun sendMail(mailRequest: MailRequest, attachments: List<File>) {
        try {
            sendTemplateMail(
                to = mailRequest.to,
                subject = mailRequest.subject,
                templateFile = mailRequest.templateFile,
                templateMap = mailRequest.templateMap,
                locale = mailRequest.locale,
                attachments = attachments
            )
        } catch (e: Throwable) {
            // 451 5.7.3 STARTTLS is required to send mail
            if (e is MessagingException && e.message?.contains("STARTTLS is required to send mail") == true) {
                log.error("Could not send email: ${e.message}", e)
                throw MailError.SendingFailedMisconfiguredServer(e::class.simpleName, e.message ?: "STARTTLS is required")
            } else {
                log.error("Could not send email: ${e.message}", e)
                log.error("Could not send email: ${e.message}", e)
                throw MailError.SendingFailedServerError(e::class.simpleName, e.message)
            }
        }
    }

    @Throws(MessagingException::class)
    private fun sendTemplateMail(
        to: String,
        subject: String,
        templateFile: String,
        templateMap: Map<String, Any>,
        locale: Locale,
        attachments: List<File>
    ) {
        val freemarkerTemplate: Template = freemarkerConfigurer.configuration.getTemplate(templateFile, locale)
        val htmlBody = FreeMarkerTemplateUtils.processTemplateIntoString(freemarkerTemplate, templateMap)
        log.info("MAIL: Sending templated mail to '$subject' $templateFile")

        if (attachments.isNotEmpty()) {
            sendHtmlMailWithAttachments(to, subject, htmlBody, attachments)
        } else {
            sendHtmlMail(to, subject, htmlBody)
        }
    }

    @Throws(MessagingException::class)
    fun sendHtmlMail(to: String, subject: String, htmlBody: String) {
        val message = mailSender.createMimeMessage()
        val helper = MimeMessageHelper(message, true, "UTF-8")

        System.setProperty("mail.mime.charset", "utf8")
        helper.setTo(to)
        helper.setSubject(subject)
        helper.setText(htmlBody, true)
        helper.setFrom(senderFrom, senderName)
        mailSender.send(message)
    }

    @Throws(MessagingException::class)
    fun sendHtmlMailWithAttachments(to: String, subject: String, htmlBody: String, attachments: List<File>) {
        val message = mailSender.createMimeMessage()
        val helper = MimeMessageHelper(message, true, "UTF-8")

        helper.setTo(to)
        helper.setSubject(subject)
        helper.setText("")
        helper.setText(htmlBody, true)
        helper.setFrom(senderFrom, senderName)

        attachments.forEach {
            helper.addAttachment(it.name, it)
        }
        mailSender.send(message)
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
