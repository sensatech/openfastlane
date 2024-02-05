package at.sensatech.openfastlane.api.testcommons

import at.sensatech.openfastlane.common.ApplicationProfiles
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.servlet.handler.HandlerMappingIntrospector

@Profile(ApplicationProfiles.TEST)
@Configuration
@EnableMethodSecurity
class TestSecurityConfiguration {
    @Bean
    fun testSecurityChain(httpSecurity: HttpSecurity, introspector: HandlerMappingIntrospector): SecurityFilterChain {
        TestHttpSecurityConfig().configure(httpSecurity, introspector)
        return httpSecurity.build()
    }
}
