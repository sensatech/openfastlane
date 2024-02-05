package at.sensatech.openfastlane.server.config.security

import at.sensatech.openfastlane.api.common.OflAuthentication
import at.sensatech.openfastlane.api.config.OflHttpSecurityConfig
import at.sensatech.openfastlane.common.ApplicationProfiles
import org.slf4j.LoggerFactory
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.web.client.RestTemplateBuilder
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import org.springframework.core.convert.converter.Converter
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.oauth2.server.resource.OAuth2ResourceServerConfigurer
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.server.resource.authentication.BearerTokenAuthentication
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.security.web.SecurityFilterChain
import org.springframework.web.client.RestOperations
import org.springframework.web.servlet.handler.HandlerMappingIntrospector
import java.time.Duration

@Profile(ApplicationProfiles.NOT_TEST)
@Configuration
@ConfigurationProperties(prefix = "spring.security.oauth2.resourceserver.jwt")
internal class SecurityConfiguration {

    val securityConfig = OflHttpSecurityConfig()
    private val log = LoggerFactory.getLogger(this::class.java)

    init {
        log.debug("security configuration processing...")
    }

    lateinit var jwkSetUri: String

    @Bean
    @Throws(Exception::class)
    fun filterChain(http: HttpSecurity, introspector: HandlerMappingIntrospector): SecurityFilterChain? {

        http.oauth2ResourceServer { oauth2: OAuth2ResourceServerConfigurer<HttpSecurity?> ->
            oauth2.jwt { securityJwtConfigurer ->
                securityJwtConfigurer.decoder(jwtDecoder())
                    .jwtAuthenticationConverter(customJwtAuthenticationConverter())
            }
        }
        securityConfig.configure(http, introspector)
        http.authenticationProvider(OflAuthenticationProvider())
        return http.build()
    }

    private fun jwtDecoder(): NimbusJwtDecoder? {
        val rest: RestOperations =
            RestTemplateBuilder().setConnectTimeout(Duration.ofSeconds(10)).setReadTimeout(Duration.ofSeconds(10))
                .build()
        return NimbusJwtDecoder.withJwkSetUri(jwkSetUri).restOperations(rest).build()
    }

    fun customJwtAuthenticationConverter(): JwtAuthenticationConverter {
        val converter = JwtAuthenticationConverter()
        converter.setJwtGrantedAuthoritiesConverter(ScopeFixingJwtGrantedAuthoritiesConverter())
        return converter
    }
}

class OflAuthenticationProvider : AuthenticationProvider {
    override fun authenticate(authentication: Authentication?): Authentication {
        if (authentication is JwtAuthenticationToken) {
            return OflAuthentication(
                authentication.principal,
                authentication.credentials,
                authentication.authorities
            )
        } else if (authentication is BearerTokenAuthentication) {
            return OflAuthentication(
                authentication.principal,
                authentication.credentials,
                authentication.authorities
            )
        } else {
            throw IllegalStateException("AuthenticationToken is still not supported: $authentication")
        }
    }

    override fun supports(authentication: Class<*>?): Boolean {
        return JwtAuthenticationToken::class.java.isAssignableFrom(authentication) or BearerTokenAuthentication::class.java.isAssignableFrom(
            authentication
        )
    }
}

class ScopeFixingJwtGrantedAuthoritiesConverter : Converter<Jwt, Collection<GrantedAuthority>> {

    override fun convert(source: Jwt): Collection<GrantedAuthority> {
        val claims = source.claims
        val allRoles = HashSet<String>()
        if (claims["roles"] != null) {
            val stringAnyMap = claims["roles"] as List<String>
            allRoles.addAll(stringAnyMap)
        }
        if (claims["realm_access"] != null) {
            val realmAccess = claims["realm_access"] as Map<String, Any>
            val realmAccessRoles = realmAccess["roles"] as List<String>
            allRoles.addAll(realmAccessRoles)
        }
        return allRoles.distinct().map {
            SimpleGrantedAuthority("ROLE_" + it.uppercase())
        }
    }
}
