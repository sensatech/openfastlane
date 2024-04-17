package at.sensatech.openfastlane.documents.exports

import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.Person

class ExportLineItem(
    val person: Person,
    val consumption: Consumption,
)
