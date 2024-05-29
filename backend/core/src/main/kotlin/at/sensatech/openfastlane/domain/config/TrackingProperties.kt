package at.sensatech.openfastlane.domain.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties(prefix = "openfastlane.tracking")
class TrackingProperties {

    var piwikRootUrl: String = ""
    var piwikSiteId: String = ""
}
