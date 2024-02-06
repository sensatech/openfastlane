package at.sensatech.openfastlane.domain.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Configuration
import org.springframework.security.web.util.UrlUtils

@Configuration
class RestConstantsService(
    @Value("\${openfastlane.root-url}") val _rootUrl: String
) {

    private lateinit var parsedUrl: String

    fun getRootUrl(): String = _rootUrl.apply {
        val isUrl = UrlUtils.isAbsoluteUrl(_rootUrl)
        if (_rootUrl.isBlank() || !isUrl || _rootUrl.contains("localhost")) {
            throw java.lang.IllegalStateException("openfastlane.root-url must be provided with a valid absolute URL: $_rootUrl")
        }
        parsedUrl = _rootUrl.removeSuffix("/")
    }
}
