package at.sensatech.openfastlane.api.common

import at.sensatech.openfastlane.domain.exceptions.UnauthorizedException
import at.sensatech.openfastlane.security.OflUser
import org.slf4j.LoggerFactory
import org.springframework.core.MethodParameter
import org.springframework.security.core.context.SecurityContextHolder
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken
import org.springframework.web.bind.support.WebDataBinderFactory
import org.springframework.web.context.request.NativeWebRequest
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.method.support.ModelAndViewContainer

class OflAuthenticationResolver : HandlerMethodArgumentResolver {

    override fun supportsParameter(parameter: MethodParameter): Boolean {
        return parameter.parameterType.equals(OflUser::class.java)
    }

    override fun resolveArgument(
            parameter: MethodParameter,
            mavContainer: ModelAndViewContainer?,
            webRequest: NativeWebRequest,
            binderFactory: WebDataBinderFactory?,
    ): OflUser {
        val authentication = SecurityContextHolder.getContext().authentication
        if (!authentication.isAuthenticated) {
            log.error("resolve own Account using JWT: isAuthenticated=${authentication.isAuthenticated} must fail")
            throw UnauthorizedException("Token details can not be resolved in current context")

        }

        if (authentication.principal is OflAuthentication) {
            return (authentication.principal as OflAuthentication).requireAdminUser()
        }

        if (authentication.principal is OflUserDetails) {
            log.debug("resolve own Account using JWT: isAuthenticated=${authentication.isAuthenticated}, subject=${authentication.name}")
            return (authentication.principal as OflUserDetails).requireAdminUser()
        }

        if (authentication is JwtAuthenticationToken) {
            log.debug("resolve own Account using JWT: isAuthenticated=${authentication.isAuthenticated}, subject=${authentication.name}")
            log.debug("resolve own Account using JWT: authentication.principal=${authentication.principal}")
            log.debug("resolve own Account using JWT: authentication.details=${authentication.details}")
            if (authentication.principal is Jwt) {
                return (authentication.principal as Jwt).toUser()
                        ?: throw IllegalStateException("User is not an AdminUser")
            }
        }

        log.error("resolve own Account using JWT: isAuthenticated=${authentication.isAuthenticated} must fail")
        throw UnauthorizedException("Token details can not be resolved in current context")
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
