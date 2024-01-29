package at.sensatech.openfastlane.server.config

import com.fasterxml.jackson.databind.*
import com.fasterxml.jackson.databind.json.JsonMapper
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule
import com.fasterxml.jackson.module.kotlin.kotlinModule

class SimpleJsonObjectMapper private constructor() : ObjectMapper() {

    override fun copy(): JsonMapper {
        return create()
    }

    companion object {
        fun create(): JsonMapper {
            return JsonMapper.builder()
                .addModule(kotlinModule())
                .addModule(JavaTimeModule())
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
                .configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, true)
                .enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS)
                .propertyNamingStrategy(PropertyNamingStrategies.LOWER_CAMEL_CASE)
                .build()
        }
    }
}
