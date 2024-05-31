package at.sensatech.openfastlane.tracking

data class HttpTrackingEvent(
    val url: String,
    override val eventCategory: String,
    override val eventAction: String,
    override val eventName: String,
    override val eventValue: Int = 0,
    val session: String,
    val statusCode: Int,
) : TrackingEvent {
    override fun transformToMap(timestamp: String): MutableMap<String, Any> =
        super.transformToMap(timestamp).apply {
            put("status_code", statusCode)
            put("session", session)
            put("url", url)
        }
}
