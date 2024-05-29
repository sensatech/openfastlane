package at.sensatech.openfastlane.domain.events

import at.sensatech.openfastlane.tracking.ActionEvent

open class EntitlementEvent(
    eventAction: EventActions,
    override val eventName: String,
    override val eventValue: Int = 0,
) : ActionEvent("Entitlements", eventAction.name, eventName, eventValue) {

    class Create(info: String, length: Int) :
        EntitlementEvent(eventAction = EventActions.CREATE, eventName = "create entitlement $info", eventValue = length)

    class Update(info: String, length: Int) :
        EntitlementEvent(eventAction = EventActions.UPDATE, eventName = "update entitlement $info", eventValue = length)

    class Extend : EntitlementEvent(eventAction = EventActions.UPDATE, eventName = "extend entitlement")
    class View : EntitlementEvent(eventAction = EventActions.VIEW, eventName = "view entitlement")
    class UpdateQrCode : EntitlementEvent(eventAction = EventActions.UPDATE, eventName = "update qr")
    class ViewQrCode : EntitlementEvent(eventAction = EventActions.VIEW, eventName = "view qr")
    class SendQrCode : EntitlementEvent(eventAction = EventActions.SEND, eventName = "send qr")
    class ViewPersonEntitlements :
        EntitlementEvent(eventAction = EventActions.LIST, eventName = "view person entitlements")

    class List : EntitlementEvent(eventAction = EventActions.LIST, eventName = "list entitlements")
}
