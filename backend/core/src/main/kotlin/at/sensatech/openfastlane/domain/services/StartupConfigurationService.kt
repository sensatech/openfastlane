package at.sensatech.openfastlane.domain.services

import org.springframework.core.io.Resource

interface StartupConfigurationService {
    fun loadStartupConfiguration(campaignsJsonResource: Resource): Boolean
}
