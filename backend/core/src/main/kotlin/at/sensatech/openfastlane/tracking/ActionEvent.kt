package at.sensatech.openfastlane.tracking

open class ActionEvent(
    override val eventCategory: String,
    override val eventAction: String,
    override val eventName: String,
    override val eventValue: Int = 0,
) : TrackingEvent {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ActionEvent

        if (eventCategory != other.eventCategory) return false
        if (eventAction != other.eventAction) return false
        if (eventName != other.eventName) return false
        if (eventValue != other.eventValue) return false
        return true
    }

    override fun hashCode(): Int {
        var result = eventCategory.hashCode()
        result = 31 * result + eventAction.hashCode()
        result = 31 * result + eventName.hashCode()
        result = 31 * result + eventValue
        return result
    }
}
