package at.sensatech.openfastlane.mailing

import at.sensatech.openfastlane.domain.config.OflMailSenderConfiguration
import freemarker.cache.ClassTemplateLoader
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.domain.EntityScan
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.web.servlet.view.freemarker.FreeMarkerConfigurer

@EntityScan(basePackageClasses = [MailingModule::class])
@Configuration
class MailingModule {

    @Suppress("unused")
    @Autowired
    private lateinit var javaMailSender: JavaMailSender

    @Bean
    fun freemarkerClassLoaderConfig(): FreeMarkerConfigurer {
        val configuration = freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_27).apply {
            setDefaultEncoding("UTF-8")
            templateLoader = ClassTemplateLoader(this.javaClass, "/mail-templates")
        }
        return FreeMarkerConfigurer().apply {
            this.configuration = configuration
        }
    }

    @Bean
    fun mailService(
        javaMailSender: JavaMailSender,
        freeMarkerConfigurer: FreeMarkerConfigurer,
        mailSenderConfiguration: OflMailSenderConfiguration
    ): MailService {
        return MailServiceSmtpImpl(
            javaMailSender,
            freeMarkerConfigurer,
            mailSenderConfiguration,
        )
    }
}
