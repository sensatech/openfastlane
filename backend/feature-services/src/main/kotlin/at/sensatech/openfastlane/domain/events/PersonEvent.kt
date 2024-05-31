package at.sensatech.openfastlane.domain.events

import at.sensatech.openfastlane.tracking.ActionEvent

open class PersonEvent(
    eventAction: EventActions,
    override val eventName: String,
    override val eventValue: Int = 0,
) : ActionEvent("Persons", eventAction.name, eventName, eventValue) {

    class Create(info: String) : PersonEvent(eventAction = EventActions.CREATE, eventName = "create person $info")
    class View : PersonEvent(eventAction = EventActions.VIEW, eventName = "view person")
    class ViewSimilar : PersonEvent(eventAction = EventActions.LIST, eventName = "view similar persons")
    class List : PersonEvent(eventAction = EventActions.LIST, eventName = "list persons")
    class SearchName(length: Int) :
        PersonEvent(eventAction = EventActions.SEARCH, eventName = "search person name", eventValue = length)

    class SearchAddress(length: Int) :
        PersonEvent(eventAction = EventActions.SEARCH, eventName = "search person address", eventValue = length)

    class SearchFind(length: Int) :
        PersonEvent(eventAction = EventActions.SEARCH, eventName = "search person address", eventValue = length)

    class Update : PersonEvent(eventAction = EventActions.UPDATE, eventName = "update person")
    class UpdateLinkedPerson : PersonEvent(eventAction = EventActions.UPDATE, eventName = "update linked person")
}
