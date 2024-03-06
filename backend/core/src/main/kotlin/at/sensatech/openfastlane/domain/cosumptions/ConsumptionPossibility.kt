package at.sensatech.openfastlane.domain.cosumptions

enum class ConsumptionPossibility {
    REQUEST_INVALID,
    ENTITLEMENT_INVALID,
    ENTITLEMENT_EXPIRED,
    CONSUMPTION_ALREADY_DONE,
    CONSUMPTION_POSSIBLE,
}
