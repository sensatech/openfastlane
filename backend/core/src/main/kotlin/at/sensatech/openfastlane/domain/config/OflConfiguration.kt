package at.sensatech.openfastlane.domain.config

import jakarta.validation.constraints.NotBlank
import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "openfastlane")
class OflConfiguration {
    @NotBlank
    var webBaseUrl: String = ""

    @NotBlank
    var apiBaseUrl: String = ""
}
