package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.config.OflMailSenderConfiguration
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import jakarta.mail.internet.MimeMessage
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer
import java.util.Locale

class MailServiceSmtpImplTest {

    private val mailSender: JavaMailSender = mockk(relaxed = true) {
        every { createMimeMessage() } returns mockk(relaxed = true)
    }
    private val configuration: freemarker.template.Configuration = mockk {
        every { getTemplate(any()) } returns mockk(relaxed = true)
        every { getTemplate(any(), any<Locale>()) } returns mockk(relaxed = true)
    }

    private val freemarkerConfigurer: FreeMarkerConfigurer = mockk(relaxed = true) {
        every { configuration } returns this@MailServiceSmtpImplTest.configuration
    }

    private val senderConfiguration: OflMailSenderConfiguration = mockk(relaxed = true)

    private val subject = MailServiceSmtpImpl(
        mailSender,
        freemarkerConfigurer,
        senderConfiguration,
    )

    @Test
    fun `sendMail should resolve template`() {

        subject.sendMail(
            MailRequest(
                subject = "Custom subject",
                to = "test@example.com",
                templateFile = "one certain template",
                templateMap = mapOf(),
                locale = Locale.GERMAN,
            ),
            emptyList()
        )

        verify { configuration.getTemplate(eq("one certain template"), eq(Locale.GERMAN)) }
    }

    @Test
    fun `sendMail should resolve template with i18n`() {

        val mailRequest = MailRequest(
            subject = "Custom subject",
            to = "test@example.com",
            templateFile = "template",
            templateMap = mapOf(),
            locale = Locale.GERMAN,
        )

        subject.sendMail(mailRequest, emptyList())
        verify { configuration.getTemplate(eq("template"), eq(Locale.GERMAN)) }

        subject.sendMail(mailRequest.copy(locale = Locale.ENGLISH), emptyList())
        verify { configuration.getTemplate(eq("template"), eq(Locale.GERMAN)) }
    }

    @Test
    fun `sendMail should send mail`() {
        subject.sendMail(
            MailRequest(
                subject = "Custom subject",
                to = "test@example.com",
                templateFile = "one certain template",
                templateMap = mapOf(),
                locale = Locale.GERMAN,
            ),
            emptyList()
        )

        verify { mailSender.send(any<MimeMessage>()) }
    }

    @Test
    fun `sendMail should throw SendFailed exception`() {
        every { mailSender.send(any<MimeMessage>()) } throws Throwable("Internet not working today")

        assertThrows<MailError.SendFailed> {
            subject.sendMail(
                MailRequest(
                    subject = "Custom subject",
                    to = "test@example.com",
                    templateFile = "one certain template",
                    templateMap = mapOf(),
                    locale = Locale.GERMAN,
                ),
                emptyList()
            )
        }
    }
}
