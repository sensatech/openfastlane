package at.sensatech.openfastlane.domain.events

import at.sensatech.openfastlane.tracking.ActionEvent

open class MailEvent(
    eventAction: EventActions,
    override val eventName: String,
    override val eventValue: Int = 0,
) : ActionEvent("Mail", eventAction.name, eventName, eventValue) {

    class Success : MailEvent(eventAction = EventActions.SEND, eventName = "mail success")
    class Failure(info: String) :
        MailEvent(eventAction = EventActions.SEND, eventName = "mail failure $info")
}
