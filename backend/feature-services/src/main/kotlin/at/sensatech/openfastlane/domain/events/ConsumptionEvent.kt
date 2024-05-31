package at.sensatech.openfastlane.domain.events

import at.sensatech.openfastlane.tracking.ActionEvent

open class ConsumptionEvent(
    eventAction: EventActions,
    override val eventName: String,
    override val eventValue: Int = 0,
) : ActionEvent("Consumption", eventAction.name, eventName, eventValue) {

    class Check(info: String) : ConsumptionEvent(eventAction = EventActions.VIEW, eventName = "check $info")
    class CheckResult(info: String, result: String) :
        ConsumptionEvent(eventAction = EventActions.CHECK, eventName = "check $info -> $result")

    class Consume(info: String) : ConsumptionEvent(eventAction = EventActions.CONSUME, eventName = "consume $info")
    class Export(info: String, length: Int) :
        ConsumptionEvent(eventAction = EventActions.EXPORT, eventName = "export $info", eventValue = length)

    class List : ConsumptionEvent(eventAction = EventActions.LIST, eventName = "list consumptions")
}
