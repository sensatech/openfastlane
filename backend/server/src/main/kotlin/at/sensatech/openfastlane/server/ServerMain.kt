package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.domain.DomainModule
import at.sensatech.openfastlane.domain.config.OflConfiguration
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Import
import org.springframework.scheduling.annotation.EnableScheduling

@EnableScheduling
@SpringBootApplication(
    scanBasePackages = [
        "at.sensatech.openfastlane"
    ],
)
@ConfigurationPropertiesScan
@EnableConfigurationProperties(value = [OflConfiguration::class])
@Import(
    value = [
        DomainModule::class,
    ]
)
class ServerMain

fun main(args: Array<String>) {
    runApplication<ServerMain>(*args)
}
