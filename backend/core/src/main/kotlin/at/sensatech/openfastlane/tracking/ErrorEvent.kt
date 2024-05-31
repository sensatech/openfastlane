package at.sensatech.openfastlane.tracking

data class ErrorEvent(
    override val eventCategory: String,
    override val eventAction: String,
    override val eventName: String,
    override val eventValue: Int = 0,
    val exception: Exception,
) : TrackingEvent {
    override fun transformToMap(timestamp: String): MutableMap<String, Any> =
        super.transformToMap(timestamp).apply {
            put("exception", exception.message ?: exception.toString())
        }
}
