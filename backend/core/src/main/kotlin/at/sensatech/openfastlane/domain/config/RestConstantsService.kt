package at.sensatech.openfastlane.domain.config

import org.springframework.context.annotation.Configuration
import org.springframework.security.web.util.UrlUtils

@Configuration
class RestConstantsService(
    val config: OflConfiguration
) {


    fun setup() {
        checkUrl(config.webBaseUrl, "webBaseUrl")
    }

    fun getWebBaseUrl(): String = config.webBaseUrl

    private final fun checkUrl(baseUrl: String, name: String): String = baseUrl.apply {
        val isUrl = UrlUtils.isAbsoluteUrl(baseUrl)
        if (baseUrl.isBlank() || !isUrl) {
            throw java.lang.IllegalStateException("openfastlane.$name must be provided with a valid absolute URL: $baseUrl")
        }
    }
}
