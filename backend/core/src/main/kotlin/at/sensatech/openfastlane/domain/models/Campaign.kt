package at.sensatech.openfastlane.domain.models

import org.springframework.data.annotation.Id
import org.springframework.data.mongodb.core.mapping.Document

@Document
data class Campaign(
        @Id
        val id: String,
        val name: String,
        val period: Period
)