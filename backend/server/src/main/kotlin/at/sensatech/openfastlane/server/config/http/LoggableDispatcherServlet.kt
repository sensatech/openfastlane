package at.sensatech.openfastlane.server.config.http

import at.sensatech.openfastlane.tracking.HttpTrackingEvent
import at.sensatech.openfastlane.tracking.TrackingContext
import at.sensatech.openfastlane.tracking.TrackingService
import jakarta.annotation.Resource
import jakarta.servlet.annotation.MultipartConfig
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.web.servlet.DispatcherServlet

@MultipartConfig
class LoggableDispatcherServlet(private val trackingService: TrackingService) : DispatcherServlet() {

    @Resource(name = "sessionScopedTrackingContext")
    var sessionTrackingContext: TrackingContext? = null

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }

    override fun doDispatch(request: HttpServletRequest, response: HttpServletResponse) {

        val method = request.method
        val url = request.requestURI.toString()
        val session = request.session.id

        if (url.contains("actuator")) {
            super.doDispatch(request, response)
            return
        }

        sessionTrackingContext?.let {
            it.method = method ?: it.method
            it.url = url
            it.session = session ?: it.session
        }

        val event = HttpTrackingEvent(
            eventCategory = "Http",
            eventAction = method,
            eventName = url,
            eventValue = response.status,
            url = url,
            session = session,
            statusCode = response.status,
        )
        trackingService.track(event)
        if (response.status >= 400) {
            log.warn("HTTP: $session $method $url")
        } else {
            log.info("HTTP: $session $method $url")
        }
        super.doDispatch(request, response)
    }
}
