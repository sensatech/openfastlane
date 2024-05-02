package at.sensatech.openfastlane.mocks

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaOption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.models.Person
import java.time.LocalDate
import java.time.ZonedDateTime

object Mocks {

    fun mockPerson(
        id: String = newId(),
        firstName: String = "Unnamed",
        lastName: String = "Mocky",
        dateOfBirth: LocalDate? = LocalDate.of(1980, 10, 10),
        addressSuffix: String = "1",
        email: String = "mail@example.com",
        mobileNumber: String = "+43 123 456 789",
        addressId: String = newId()
    ): Person {
        return Person(
            id = id,
            firstName = firstName,
            lastName = lastName,
            dateOfBirth = dateOfBirth,
            gender = Gender.DIVERSE,
            address = Address(
                addressId = addressId,
                streetNameNumber = "Hausgasse 1",
                addressSuffix = addressSuffix,
                postalCode = "1010",
            ),
            email = email,
            mobileNumber = mobileNumber,
            comment = "",
            createdAt = ZonedDateTime.now(),
            updatedAt = ZonedDateTime.now(),
            similarPersonIds = setOf(),
        )
    }

    fun mockEntitlement(
        personId: String,
        entitlementCauseId: String = newId(),
        campaignId: String = newId()
    ): Entitlement {
        return Entitlement(
            id = newId(),
            personId = personId,
            entitlementCauseId = entitlementCauseId,
            campaignId = campaignId,
            status = EntitlementStatus.PENDING,
            values = arrayListOf(
                EntitlementValue(
                    criteriaId = "TEXT",
                    type = EntitlementCriteriaType.TEXT,
                    value = "Entitlement Value"
                )
            ),
            expiresAt = ZonedDateTime.now().plusYears(1)
        )
    }

    fun mockConsumption(
        personId: String,
        entitlementId: String,
        entitlementCauseId: String,
        campaignId: String,
        consumedAt: ZonedDateTime = ZonedDateTime.now(),
        entitlementData: List<EntitlementValue> = emptyList()
    ): Consumption {
        return Consumption(
            id = newId(),
            personId = personId,
            entitlementId = entitlementId,
            entitlementCauseId = entitlementCauseId,
            campaignId = campaignId,
            consumedAt = consumedAt,
            entitlementData = entitlementData
        )
    }

    fun mockCampaign(
        id: String = newId(),
        name: String = "New Campaign",
    ): Campaign {
        return Campaign(
            id = id,
            name = name,
            period = Period.YEARLY
        )
    }

    fun mockEntitlementCause(
        id: String = newId(),
        campaignId: String = newId(),
        name: String = "New Campaign's Cause",
    ): EntitlementCause {
        return EntitlementCause(
            id = id,
            campaignId = campaignId,
            name = name,
            criterias = arrayListOf(
                EntitlementCriteria(
                    name = "TEXT",
                    type = EntitlementCriteriaType.TEXT,
                    reportKey = "reportKey"
                ),
                EntitlementCriteria(
                    name = "CHECKBOX",
                    type = EntitlementCriteriaType.CHECKBOX,
                    reportKey = "reportKey"
                ),
                EntitlementCriteria(
                    name = "INTEGER",
                    type = EntitlementCriteriaType.INTEGER,
                    reportKey = "reportKey"
                ),
                EntitlementCriteria(
                    name = "OPTIONS",
                    type = EntitlementCriteriaType.OPTIONS,
                    options = arrayListOf(
                        EntitlementCriteriaOption(key = "option1", label = "Option 1"),
                        EntitlementCriteriaOption(key = "option2", label = "Click Option 2"),
                    ),
                    reportKey = "reportKey"
                ),
                EntitlementCriteria(
                    name = "FLOAT",
                    type = EntitlementCriteriaType.FLOAT,
                    reportKey = "reportKey"
                ),
            )
        )
    }
}
