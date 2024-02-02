package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.server.config.SimpleJsonObjectMapper
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties
class MainServerModule {

    @Bean
    fun objectMapper(): ObjectMapper {
        return SimpleJsonObjectMapper.create()
    }

}
