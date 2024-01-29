package at.sensatech.openfastlane.testcommons

import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class TestMappingConfig {
    @Bean
    fun objectMapper(): ObjectMapper {
        return TestSimpleJsonObjectMapper.create()
    }
}
