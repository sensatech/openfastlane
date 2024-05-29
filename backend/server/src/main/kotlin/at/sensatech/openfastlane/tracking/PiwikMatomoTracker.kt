package at.sensatech.openfastlane.tracking

import at.sensatech.openfastlane.tracking.TrackingConfiguration.Companion.serverStartedEvent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.slf4j.LoggerFactory
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatusCode
import org.springframework.http.MediaType
import org.springframework.web.client.RestTemplate
import kotlin.math.min
import kotlin.random.Random

class PiwikMatomoTracker(
    private val webBaseUrl: String,
    private val piwikRootUrl: String,
    private val piwikSiteId: String
) : TrackingService {

    private val eventFlow = MutableSharedFlow<TrackingEvent>()

    private val scope = CoroutineScope(Dispatchers.IO)
    private var ready = false

    override fun setup() {
        log.info("Setup PiwikMatomoTracker with siteId: ${piwikSiteId.substring(0, min(piwikSiteId.length, 8))}.. ")
        ready = piwikSiteId.isNotBlank() && piwikRootUrl.isNotBlank()
        if (ready) {
            scope.launch {
                eventFlow.onEach {
                    sendToPiwik(event = it)
                }.collect()
            }
            log.info("Event buffer tracking started")
        } else {
            log.warn("no tracking queue, PiwikMatomoTracker not ready")
        }
    }

    override fun checkHealth(): Boolean {
        if (!ready) {
            log.error(" Not setup, therefore not working")
            return false
        }

        return try {
            val sendHttpTracking = sendHttpTracking(serverStartedEvent(webBaseUrl))
            if (sendHttpTracking.isError) {
                log.error("PiwikMatomoTracker is not sending properly: $sendHttpTracking")
            }
            sendHttpTracking.is2xxSuccessful
        } catch (e: Exception) {
            log.error("PiwikMatomoTracker is not working properly: ${e.message}")
            log.warn(e.message, e)
            false
        }
    }

    override fun track(event: TrackingEvent, instant: Boolean) {
        if (!ready) {
            log.warn("sendEvent $event omitted, PiwikMatomoTracker not ready")
            return
        }
        if (instant) {
            scope.launch {
                sendToPiwik(event)
            }
        } else {
            scope.launch {
                eventFlow.emit(event)
            }
        }
    }

    private suspend fun sendToPiwik(event: TrackingEvent) {
        val headers = HttpHeaders()
        headers.contentType = MediaType.APPLICATION_JSON

        withContext(Dispatchers.IO) {
            try {
                sendHttpTracking(event)
            } catch (e: Exception) {
                log.error("send event: $event -> ${e.message}")
                log.warn(e.message, e)
            }
        }
    }

    private fun sendHttpTracking(event: TrackingEvent): HttpStatusCode {
        val restTemplate = RestTemplate()
        val eventCategory = event.eventCategory
        val eventAction = event.eventAction
        val eventName = event.eventName
        val eventValue = event.eventValue
        val rec = "1"
        val r = Random.nextLong()
        val actionParams = "&e_c=$eventCategory&e_a=$eventAction&e_n=$eventName&e_v=$eventValue"
        val responseEntity = restTemplate.getForEntity(
            "$piwikRootUrl/ppms.php?idsite=$piwikSiteId&rec=$rec&rand=$r&apiv=1$actionParams",
            Unit::class.java,
        )
        return responseEntity.statusCode
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
