package at.sensatech.openfastlane.tracking

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.config.OflConfiguration
import at.sensatech.openfastlane.domain.config.TrackingProperties
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile

@Configuration
@Profile(ApplicationProfiles.NOT_TEST)
class TrackingConfiguration {

    @Autowired
    lateinit var properties: TrackingProperties

    @Autowired
    lateinit var oflConfiguration: OflConfiguration

    @Bean
    fun trackingService(): TrackingService? {
        val trackingServices = ArrayList<TrackingService>()
        if (properties.piwikSiteId.isNotBlank() && properties.piwikRootUrl.isNotBlank()) {
            trackingServices.add(
                PiwikMatomoTracker(
                    oflConfiguration.webBaseUrl,
                    properties.piwikRootUrl,
                    properties.piwikSiteId
                )
            )
        }
        log.info("Add all TrackingServices: $trackingServices")
        return TrackingServiceDelegate(trackingServices)
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
        fun serverStartedEvent(rootUrl: String) = ActionEvent("technical", "server_started", rootUrl, 0)
    }
}
