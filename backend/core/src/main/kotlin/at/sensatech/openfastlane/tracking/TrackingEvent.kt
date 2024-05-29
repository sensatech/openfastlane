package at.sensatech.openfastlane.tracking

interface TrackingEvent {
    val eventCategory: String
    val eventAction: String
    val eventName: String
    val eventValue: Int

    fun transformToMap(timestamp: String): MutableMap<String, Any> = hashMapOf(
        "timestamp" to timestamp,
        "event_category" to eventCategory,
        "action_action" to eventAction,
        "event_name" to eventName,
        "event_value" to eventValue,
    )
}
