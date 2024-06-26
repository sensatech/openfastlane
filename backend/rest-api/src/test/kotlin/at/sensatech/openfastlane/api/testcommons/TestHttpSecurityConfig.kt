package at.sensatech.openfastlane.api.testcommons

import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.servlet.util.matcher.MvcRequestMatcher
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.servlet.handler.HandlerMappingIntrospector

class TestHttpSecurityConfig {

    fun configure(http: HttpSecurity, introspector: HandlerMappingIntrospector) {
        http
            .exceptionHandling {
                it.authenticationEntryPoint { _, response, authException ->
                    response.status = HttpStatus.UNAUTHORIZED.value()
                    response.contentType = "application/json"
                    response.writer.write("{ \"error\": \"${authException.message}\" }")
                }
            }
            .cors { corsConfigurer ->
                corsConfigurer.configurationSource { _ ->
                    val cors = CorsConfiguration()
                    cors.allowedOriginPatterns = listOf(
                        "http://localhost:9080",
                        "http://10.24.9.197:9080",
                        "https://10.24.9.197:9080",
                        "https://10.24.9.197:9081",
                        "https://staging.openfastlane.at",
                        "https://app.openfastlane.at",
                    )
                    cors.allowedMethods = listOf("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                    cors.allowedHeaders = listOf("*")
                    cors.allowCredentials = true
                    cors.exposedHeaders = listOf("Authorization")
                    cors
                }
            }
            .sessionManagement {
                it.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            }
            .anonymous {}
            .authorizeHttpRequests {
                val match = MvcRequestMatcher.Builder(introspector)
                it.requestMatchers(
                    match.pattern("/docs/**"),
                    match.pattern("/error"),
                    match.pattern("/favicon.ico"),
                    match.pattern("/actuator/**"),
                    // IMPORTANT: Flo! For tests, you NEED to put it into OflHttpSecurityConfig
                    match.pattern(WEBHOOKS_URL),
                    // IMPORTANT: Flo! For tests, you NEED to put it into OflHttpSecurityConfig
                ).permitAll()
                it.anyRequest().authenticated()
            }
            .csrf { it.disable() }
            .logout { it.disable() }
    }

    companion object {
        private const val AUTH_REGISTER_URL = "/auth/register"
        private const val WEBHOOKS_URL = "/webhook/**"

        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
