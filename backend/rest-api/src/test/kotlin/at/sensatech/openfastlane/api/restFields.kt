package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.testcommons.docs
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibilityType
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Period
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType

fun personsFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "firstName", JsonFieldType.STRING, "String"),
        field(prefix + "lastName", JsonFieldType.STRING, "String"),
        field(prefix + "dateOfBirth", JsonFieldType.STRING, "LocalDate").optional(),
        field(prefix + "gender", JsonFieldType.STRING, "gender, one of ${Gender.entries.docs()}").optional(),
        field(prefix + "address", JsonFieldType.OBJECT, "address object (nullable)").optional(),
        field(prefix + "email", JsonFieldType.STRING, "email (nullable)").optional(),
        field(prefix + "mobileNumber", JsonFieldType.STRING, "mobileNumber (nullable)").optional(),
        field(prefix + "comment", JsonFieldType.STRING, "comment (nullable)").optional(),
        field(prefix + "similarPersonIds", JsonFieldType.ARRAY, "List of Ids of Similar persons, hopefully empty"),
        field(prefix + "createdAt", JsonFieldType.STRING, "createdAt"),
        field(prefix + "updatedAt", JsonFieldType.STRING, "updatedAt (nullable)").optional(),
    ).toMutableList().apply {
        addAll(addressFields(prefix + "address."))
    }
}

fun addressFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "streetNameNumber", JsonFieldType.STRING, "Streetname and number"),
        field(prefix + "addressSuffix", JsonFieldType.STRING, "Doornumber"),
        field(prefix + "postalCode", JsonFieldType.STRING, "PLZ"),
        field(prefix + "addressId", JsonFieldType.STRING, "Vienna GIS ID").optional(),
        field(prefix + "gipNameId", JsonFieldType.STRING, "Vienna GIS ID").optional(),
    )
}

fun entitlementFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementCauseId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "personId", JsonFieldType.STRING, "ObjectId of owning Person"),
        field(prefix + "values", JsonFieldType.ARRAY, "List of EntitlementValues"),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "values[]."))
    }
}

fun consumptionFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "personId", JsonFieldType.STRING, "ObjectId of owning Person"),
        field(prefix + "entitlementCauseId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "consumedAt", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "campaignId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementData", JsonFieldType.ARRAY, "List of EntitlementValues"),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "entitlementData[]."))
    }
}

fun consumptionPossibilityFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(
            prefix + "status",
            JsonFieldType.STRING,
            "ConsumptionPossibility, one of ${ConsumptionPossibilityType.entries.docs()}"
        ),
        field(
            prefix + "lastConsumptionAt",
            JsonFieldType.STRING,
            "ZonedDateTime lastConsumptionAt, (nullable)"
        ).optional(),
    )
}

fun entitlementValueFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "criteriaId", JsonFieldType.STRING, "ObjectId of EntitlementCriteria"),
        field(
            prefix + "type",
            JsonFieldType.STRING,
            "EntitlementCriteriaType, one of ${EntitlementCriteriaType.entries.docs()}"
        ),
        field(prefix + "value", JsonFieldType.STRING, "Anything, but parsed as a String!"),
    )
}

fun entitlementCauseFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "campaignId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "criterias[]", JsonFieldType.ARRAY, "List of EntitlementValues"),
    ).toMutableList().apply {
        addAll(entitlementCriteriaFields(prefix + "criterias[]."))
    }
}

fun entitlementCriteriaFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId of EntitlementCriteria"),
        field(prefix + "name", JsonFieldType.STRING, "Name of EntitlementCriteria"),
        field(
            prefix + "type",
            JsonFieldType.STRING,
            "EntitlementCriteriaType, one of ${EntitlementCriteriaType.entries.docs()}"
        ),
    )
}

fun campaignFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "name", JsonFieldType.STRING, "Name of Campaign"),
        field(prefix + "period", JsonFieldType.STRING, "Period of Campaign, one of ${Period.entries.docs()}"),
        field(
            prefix + "causes",
            JsonFieldType.ARRAY,
            "List of EntitlementValues (nullable when not requested)"
        ).optional(),
    )
}

fun campaignFieldsWithCauses(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "name", JsonFieldType.STRING, "Name of Campaign"),
        field(prefix + "period", JsonFieldType.STRING, "Period of Campaign, one of ${Period.entries.docs()}"),
        field(
            prefix + "causes",
            JsonFieldType.ARRAY,
            "List of EntitlementValues (nullable when not requested)"
        )
    ).toMutableList().apply {
        addAll(entitlementCauseFields(prefix + "causes[]."))
    }
}
