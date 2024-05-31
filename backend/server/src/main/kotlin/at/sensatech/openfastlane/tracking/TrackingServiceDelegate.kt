package at.sensatech.openfastlane.tracking

import at.sensatech.openfastlane.common.ExcludeFromJacocoGeneratedReport
import org.slf4j.LoggerFactory

@ExcludeFromJacocoGeneratedReport
class TrackingServiceDelegate(private val trackers: List<TrackingService>) : TrackingService {

    override fun setup() {
        log.info("Setup ${trackers.size} registered trackers")
        trackers.forEach { tracker ->
            tracker.setup()
        }
    }

    override fun checkHealth(): Boolean {
        var working = true
        trackers.forEach { tracker ->
            val assertWorking = tracker.checkHealth()
            if (!assertWorking) working = false
        }
        return working
    }

    override fun track(event: TrackingEvent, instant: Boolean) {
        log.debug("track event: {}", event)
        trackers.forEach { tracker ->
            tracker.track(event, instant)
        }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
