package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.config.OflConfiguration
import at.sensatech.openfastlane.domain.services.StartupConfigurationService
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.core.io.FileSystemResource
import org.springframework.stereotype.Component

@Component
class StartupConfigurationApplicationListener : ApplicationListener<ApplicationReadyEvent> {


    @Autowired
    lateinit var startupConfigurationService: StartupConfigurationService

    @Autowired
    lateinit var oflConfiguration: OflConfiguration

    @Autowired
    lateinit var oflDemoDataInitializer: OflDemoDataInitializer

    override fun onApplicationEvent(event: ApplicationReadyEvent) {

        log.info("Initializing necessary startup data...")
        val configDataDir = oflConfiguration.configDataDir
        log.info("Initializing necessary startup data... Check config dir: $configDataDir")
        val finalPath = "$configDataDir/campaigns.json"
        log.info("Initializing necessary startup data... Check campaigns.json: ${finalPath}")


        val configDir = FileSystemResource(configDataDir)
        if (!configDir.exists()) {
            throw RuntimeException("Config directory '$configDataDir' does not exist!")
        }
        val campaignsJsonResource = FileSystemResource(finalPath)
        if (!campaignsJsonResource.exists()) {
            log.warn("Campaigns JSON resource does not exist!")
            return
        }

        val success = startupConfigurationService.loadStartupConfiguration(campaignsJsonResource)
        log.info("Initializing necessary startup data... success:$success")

        if (!success) {
            log.error("Error while loading startup configuration!")
            return
        }

        if (oflConfiguration.insertDemoData) {
            log.warn("Initializing demo data...")
            oflDemoDataInitializer.insertDemoData()
        }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
