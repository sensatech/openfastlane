package at.sensatech.openfastlane.tracking

interface TrackingService {
    fun track(event: TrackingEvent, instant: Boolean = false)
    fun setup()
    fun checkHealth(): Boolean
}
