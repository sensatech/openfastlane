package at.sensatech.openfastlane.server.config.http

import at.sensatech.openfastlane.api.common.OflAuthenticationResolver
import at.sensatech.openfastlane.tracking.TrackingContext
import at.sensatech.openfastlane.tracking.TrackingService
import jakarta.servlet.MultipartConfigElement
import org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration
import org.springframework.boot.web.servlet.ServletRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.converter.BufferedImageHttpMessageConverter
import org.springframework.http.converter.HttpMessageConverter
import org.springframework.web.context.annotation.SessionScope
import org.springframework.web.filter.CommonsRequestLoggingFilter
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.multipart.support.StandardServletMultipartResolver
import org.springframework.web.servlet.DispatcherServlet
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer
import java.awt.image.BufferedImage

@Configuration
class WebConfigurer(
    val trackingService: TrackingService,
) : WebMvcConfigurer {

    override fun addArgumentResolvers(resolvers: MutableList<HandlerMethodArgumentResolver>) {
        resolvers.add(OflAuthenticationResolver())
    }

    override fun addResourceHandlers(registry: ResourceHandlerRegistry) {
        super.addResourceHandlers(registry)
        registry.addResourceHandler("/docs", "/docs/**", "/static/docs/**")
            .addResourceLocations("classpath:/static/docs/").setCachePeriod(3600 * 24)
    }

    @Bean
    fun dispatcherRegistration(): ServletRegistrationBean<DispatcherServlet> {
        val servletRegistrationBean = ServletRegistrationBean(dispatcherServlet())
        // Multipart config needs to be injected during registration, application.yml config is ignored possibly
        servletRegistrationBean.apply {
            multipartConfig = (MultipartConfigElement("/tmp"))
        }
        return servletRegistrationBean
    }


    @Bean(name = [DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_BEAN_NAME])
    fun dispatcherServlet(): DispatcherServlet {
        return LoggableDispatcherServlet(trackingService)
    }

    @Bean
    @SessionScope
    fun sessionScopedTrackingContext(): TrackingContext {
        return TrackingContext()
    }

    @Bean(name = ["multipartResolver"])
    fun multipartResolver(): StandardServletMultipartResolver {
        return StandardServletMultipartResolver()
    }

    @Bean
    fun requestLoggingFilter(): CommonsRequestLoggingFilter {
        val loggingFilter = CommonsRequestLoggingFilter()
        loggingFilter.setIncludeClientInfo(true)
        loggingFilter.setIncludeQueryString(true)
        loggingFilter.setIncludePayload(true)
        loggingFilter.setMaxPayloadLength(64000)
        return loggingFilter
    }

    @Bean
    fun createImageHttpMessageConverter(): HttpMessageConverter<BufferedImage> {
        return BufferedImageHttpMessageConverter()
    }
}
