package at.sensatech.openfastlane.domain.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties(prefix = "openfastlane.mailing")
class OflMailSenderConfiguration {
    var senderFrom: String = ""
    var senderName: String = ""
}
