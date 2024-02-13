package at.sensatech.openfastlane.mocks

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.models.Person
import java.time.LocalDate
import java.time.ZonedDateTime

object Mocks {

    fun mockPerson(
        id: String = newId(),
        firstName: String = "Adam",
        lastName: String = "Smith",
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
                streetNameNumber = "Main Street 1",
                addressSuffix = addressSuffix,
                postalCode = "1234",
            ),
            email = email,
            mobileNumber = mobileNumber,
            comment = "",
            createdAt = ZonedDateTime.now(),
            updatedAt = ZonedDateTime.now(),
            similarPersonIds = setOf(),
        )
    }

    fun mockEntitlement(personId: String): Entitlement {
        return Entitlement(
            id = newId(),
            personId = personId,
            entitlementCauseId = newId(),
            campaignId = newId(),
            values = arrayListOf(
                EntitlementValue(
                    criteriaId = newId(),
                    type = EntitlementCriteriaType.TEXT,
                    value = "Entitlement Value"
                )
            )
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
            id = newId(),
            campaignId = campaignId,
            name = name,
            criterias = arrayListOf(
                EntitlementCriteria(
                    name = "Entitlement Criteria",
                    type = EntitlementCriteriaType.TEXT,
                    reportKey = "reportKey"
                )
            )
        )
    }
}
