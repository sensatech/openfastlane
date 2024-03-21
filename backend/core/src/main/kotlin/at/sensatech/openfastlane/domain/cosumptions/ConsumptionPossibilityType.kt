package at.sensatech.openfastlane.domain.cosumptions

enum class ConsumptionPossibilityType {
    REQUEST_INVALID,
    ENTITLEMENT_INVALID,
    ENTITLEMENT_EXPIRED,
    CONSUMPTION_ALREADY_DONE,
    CONSUMPTION_POSSIBLE, ;

    fun transform(): ConsumptionPossibility {
        return ConsumptionPossibility(this)
    }
}
