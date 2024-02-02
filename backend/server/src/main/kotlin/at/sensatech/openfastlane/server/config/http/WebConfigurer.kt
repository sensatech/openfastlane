package at.sensatech.openfastlane.server.config.http

import at.sensatech.openfastlane.api.common.OflAuthenticationResolver
import jakarta.servlet.MultipartConfigElement
import org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration
import org.springframework.boot.web.servlet.ServletRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.multipart.support.StandardServletMultipartResolver
import org.springframework.web.servlet.DispatcherServlet
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class WebConfigurer(
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
        return DispatcherServlet()
    }

    @Bean(name = ["multipartResolver"])
    fun multipartResolver(): StandardServletMultipartResolver {
        return StandardServletMultipartResolver()
    }

}
