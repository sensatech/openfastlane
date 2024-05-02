package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.testcommons.docs
import at.sensatech.openfastlane.api.testcommons.field
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibilityType
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Period
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType

fun personsFields(
    prefix: String = "",
    withEntitlements: Boolean = false,
    withLastConsumptions: Boolean = false
): List<FieldDescriptor> {
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
        field(prefix + "entitlements", JsonFieldType.ARRAY, "nested Entitlements (omittable)").optional(),
        field(prefix + "lastConsumptions", JsonFieldType.ARRAY, "nested last Consumptions (omittable)").optional(),
    ).toMutableList().apply {
        addAll(addressFields(prefix + "address."))
        if (withLastConsumptions) addAll(consumptionInfoFields(prefix + "lastConsumptions[]."))
        if (withEntitlements) addAll(entitlementFields(prefix + "entitlements[]."))
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
        field(prefix + "campaignId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementCauseId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "personId", JsonFieldType.STRING, "ObjectId of owning Person"),
        field(prefix + "values", JsonFieldType.ARRAY, "List of EntitlementValues"),
        field(prefix + "createdAt", JsonFieldType.STRING, "createdAt"),
        field(prefix + "updatedAt", JsonFieldType.STRING, "updatedAt"),
        field(prefix + "expiresAt", JsonFieldType.STRING, "expiresAt (nullable)").optional(),
        field(prefix + "confirmedAt", JsonFieldType.STRING, "confirmedAt (nullable)").optional(),
        field(prefix + "audit", JsonFieldType.ARRAY, "audit").optional(),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "values[]."))
        addAll(auditItemFields(prefix + "audit[]."))
    }
}

fun consumptionFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "personId", JsonFieldType.STRING, "ObjectId of owning Person"),
        field(prefix + "entitlementCauseId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "consumedAt", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "campaignId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementData", JsonFieldType.ARRAY, "List of EntitlementValues"),
        field(prefix + "comment", JsonFieldType.STRING, "Additional info"),
    ).toMutableList().apply {
        addAll(entitlementValueFields(prefix + "entitlementData[]."))
    }
}

fun consumptionInfoFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "personId", JsonFieldType.STRING, "ObjectId of owning Person"),
        field(prefix + "campaignId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementCauseId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "entitlementId", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "consumedAt", JsonFieldType.STRING, "ObjectId"),
    )
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
        field(prefix + "name", JsonFieldType.STRING, "name"),
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
        field(prefix + "options", JsonFieldType.ARRAY, "EntitlementCriteriaOption").optional(),
    ).toMutableList().apply {
        addAll(entitlementCriteriaOptionFields(prefix + "options[]."))
    }
}

fun campaignFields(prefix: String = "", withCauses: Boolean = true): List<FieldDescriptor> {
    return listOf(
        field(prefix + "id", JsonFieldType.STRING, "ObjectId"),
        field(prefix + "name", JsonFieldType.STRING, "Name of Campaign"),
        field(prefix + "period", JsonFieldType.STRING, "Period of Campaign, one of ${Period.entries.docs()}"),
        field(prefix + "causes", JsonFieldType.ARRAY, "List of EntitlementValues (omittable)").optional()
    ).toMutableList().apply {
        if (withCauses) addAll(entitlementCauseFields(prefix + "causes[]."))
    }
}

fun auditItemFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "user", JsonFieldType.STRING, "usernane"),
        field(prefix + "action", JsonFieldType.STRING, "action"),
        field(prefix + "message", JsonFieldType.STRING, "message"),
        field(prefix + "dateTime", JsonFieldType.STRING, "dateTime"),
    )
}

fun entitlementCriteriaOptionFields(prefix: String = ""): List<FieldDescriptor> {
    return listOf(
        field(prefix + "key", JsonFieldType.STRING, "Machine readable key, eg HAUSHALTGR"),
        field(prefix + "label", JsonFieldType.STRING, "Human readable label, e.g. Hausthaltsgröße"),
        field(prefix + "order", JsonFieldType.NUMBER, "Int of ordering weight, 0 is first"),
        field(prefix + "description", JsonFieldType.STRING, "description (nullable)").optional()
    )
}
