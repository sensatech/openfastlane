package at.sensatech.openfastlane.domain.models

import org.springframework.data.mongodb.core.mapping.Document

@Document
data class Entitlement(
        val person: Person,
        val values: List<EntitlementValue>
)