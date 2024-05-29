package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.config.OflMailSenderConfiguration
import at.sensatech.openfastlane.testcontainers.ContainerHelper
import com.ninjasquad.springmockk.MockkBean
import io.mockk.every
import io.restassured.RestAssured
import io.restassured.RestAssured.given
import io.restassured.response.Response
import org.hamcrest.Matchers.containsString
import org.hamcrest.Matchers.equalTo
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.MethodOrderer
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestMethodOrder
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.mail.MailSenderAutoConfiguration
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.core.io.ResourceLoader
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.junit.jupiter.Testcontainers
import java.io.File
import java.util.Locale

@Testcontainers
@SpringBootTest(
    properties = [
        "spring.mail.host=mail",
        "spring.mail.port=8025"
    ],
    classes = [MailSenderAutoConfiguration::class, OflMailSenderConfiguration::class, MailingModule::class]
)
@TestMethodOrder(MethodOrderer.OrderAnnotation::class)
class MailingIntegrationTest {

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)

        @Container
        private val mailContainer = ContainerHelper.createEmailContainer()

        @Suppress("unused")
        @JvmStatic
        @DynamicPropertySource
        fun configureMailHost(registry: DynamicPropertyRegistry) {
            registry.add("spring.mail.host", mailContainer::getHost)
            registry.add("spring.mail.port", mailContainer::getFirstMappedPort)
            log.info("configureMailHost host=${mailContainer.host} port=${mailContainer.firstMappedPort}")
        }
    }

    @MockkBean
    private lateinit var mailSenderConfiguration: OflMailSenderConfiguration

    @Autowired
    private lateinit var subject: MailService

    @Autowired
    lateinit var resourceLoader: ResourceLoader

    @BeforeEach
    fun setupMail() {
        RestAssured.baseURI = "http://${mailContainer.host}"
        RestAssured.port = mailContainer.getMappedPort(8025)
        RestAssured.delete("/api/v1/messages")

        log.info("RestAssured.port ${RestAssured.port} ")

        every { mailSenderConfiguration.senderFrom } returns "sender@text.com"
        every { mailSenderConfiguration.senderName } returns "Sender"
        every { mailSenderConfiguration.senderName } returns "example.com"
    }

    @Nested
    inner class SendQrPdf {

        val mailRequest = MailRequests.sendQrPdf(
            to = "test@example.com",
            firstName = "MaxFirstname",
            lastName = "PowerLastname",
            locale = Locale.GERMAN,
        )

        @Test
        fun `sendQrPdf sends mail with firstname and lastname`() {

            subject.sendMail(mailRequest, emptyList())

            val messages = given().get("/api/v2/messages")
            messages.print()
            messages.then().body("total", equalTo(1))
            assertsBodyContainsString(messages, "MaxFirstname")
            assertsBodyContainsString(messages, "PowerLastname")
            assertsRecipientEqual(messages, "test@example.com")
        }

        @Test
        fun `sendQrPdf sends mail with attachments`() {

            val dataFile: File = resourceLoader.getResource("classpath:example.pdf").file

            subject.sendMail(mailRequest, listOf(dataFile))

            val messages = given().get("/api/v2/messages")
            messages.then().body("total", equalTo(1))
            messages.print()
            messages.then().body(
                "items[0].MIME.Parts[1].Headers.Content-Disposition[0]",
                containsString("attachment; filename=example.pdf")
            )
            messages.then()
                .body("items[0].MIME.Parts[1].Headers.Content-Transfer-Encoding[0]", containsString("base64"))
            messages.then().body(
                "items[0].MIME.Parts[1].Headers.Content-Type[0]",
                containsString("application/pdf; name=example.pdf")
            )
            messages.then().body("items[0].MIME.Parts[1].Body", containsString("JVBERi0xLjUKJeLjz9MKMSAwIG9i"))
            messages.then().body("items[0].MIME.Parts[1].Size", equalTo(12255))
        }

        @Test
        fun `sendQrPdf sends mail in DE`() {

            subject.sendMail(mailRequest, emptyList())

            val messages = given().get("/api/v2/messages")
            messages.print()
            messages.then().body("total", equalTo(1))
            assertsBodyContainsString(messages, "QR-Code zur Abholung bereit!")
        }

//        @Test
//        fun `sendQrPdf sends mail in EN`() {
//
//            subject.sendMail(mailRequest.copy(locale = Locale.ENGLISH))
//
//            val messages = given().get("/api/v2/messages")
//            messages.print()
//            messages.then().body("total", equalTo(1))
//            assertsBodyContainsString(messages, "Use the following pin")
//        }

        @Test
        fun `sendQrPdf in another Locale falls back to DE`() {

            subject.sendMail(mailRequest.copy(locale = Locale.JAPANESE), emptyList())

            val messages = given().get("/api/v2/messages")
            messages.print()
            messages.then().body("total", equalTo(1))
            assertsBodyContainsString(messages, "QR-Code zur Abholung bereit!")
        }
    }

    private fun assertsBodyContainsString(messages: Response, substring: String) {
        messages.then().body("items[0].Content.Body", containsString(substring))
    }

    private fun assertsRecipientEqual(messages: Response, substring: String) {
        messages.then().body("items[0].Content.Headers.To[0]", equalTo(substring))
    }
}
