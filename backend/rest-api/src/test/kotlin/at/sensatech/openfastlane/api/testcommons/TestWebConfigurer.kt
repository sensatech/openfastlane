package at.sensatech.openfastlane.api.testcommons

import at.sensatech.openfastlane.api.common.OflAuthenticationResolver
import org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration
import org.springframework.boot.web.servlet.ServletRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.method.support.HandlerMethodArgumentResolver
import org.springframework.web.servlet.DispatcherServlet
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer

@Configuration
class TestWebConfigurer : WebMvcConfigurer {

    override fun addArgumentResolvers(resolvers: MutableList<HandlerMethodArgumentResolver>) {
        resolvers.add(OflAuthenticationResolver())
    }

    override fun addResourceHandlers(registry: ResourceHandlerRegistry) {
        super.addResourceHandlers(registry)
        registry.addResourceHandler("/docs", "/docs/**", "/static/docs/**")
            .addResourceLocations("classpath:/static/docs/")
    }

    @Bean
    fun dispatcherRegistration(): ServletRegistrationBean<DispatcherServlet> {
        return ServletRegistrationBean(dispatcherServlet())
    }

    @Bean(name = [DispatcherServletAutoConfiguration.DEFAULT_DISPATCHER_SERVLET_BEAN_NAME])
    fun dispatcherServlet(): DispatcherServlet? {
        return DispatcherServlet()
    }

}
