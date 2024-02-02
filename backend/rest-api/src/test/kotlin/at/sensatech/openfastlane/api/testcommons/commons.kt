package at.sensatech.openfastlane.api.testcommons

import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType
import org.springframework.restdocs.payload.PayloadDocumentation
import org.springframework.restdocs.request.ParameterDescriptor
import org.springframework.restdocs.request.RequestDocumentation
import kotlin.enums.EnumEntries

fun field(path: String, type: JsonFieldType, description: String = "descr"): FieldDescriptor =
    PayloadDocumentation.fieldWithPath(path).type(type).description(description)

fun param(path: String, description: String = "descr"): ParameterDescriptor =
    RequestDocumentation.parameterWithName(path).description(description)

fun <T : Enum<T>> EnumEntries<T>.docs(): String {
    return this.joinToString(", ")
}