package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.config.RestConstantsService
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.event.ApplicationReadyEvent
import org.springframework.context.ApplicationListener
import org.springframework.stereotype.Component

@Component
class StartupRunner : ApplicationListener<ApplicationReadyEvent> {

    @Autowired
    lateinit var restConstantsService: RestConstantsService

    override fun onApplicationEvent(event: ApplicationReadyEvent) {
        restConstantsService.setup()
    }
}
