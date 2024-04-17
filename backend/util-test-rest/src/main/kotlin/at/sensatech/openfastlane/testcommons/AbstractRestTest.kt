package at.sensatech.openfastlane.testcommons

import at.sensatech.openfastlane.common.ApplicationProfiles
import com.fasterxml.jackson.core.type.TypeReference
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.readValue
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.mock.web.MockMultipartFile
import org.springframework.mock.web.MockPart
import org.springframework.restdocs.RestDocumentationExtension
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders
import org.springframework.restdocs.payload.FieldDescriptor
import org.springframework.restdocs.payload.JsonFieldType
import org.springframework.restdocs.payload.PayloadDocumentation
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.junit.jupiter.SpringExtension
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.ResultActions
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder
import org.springframework.test.web.servlet.request.MockMultipartHttpServletRequestBuilder
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart
import org.springframework.test.web.servlet.result.MockMvcResultMatchers

@ExtendWith(value = [RestDocumentationExtension::class, SpringExtension::class])
@ActiveProfiles(ApplicationProfiles.TEST)
@ContextConfiguration(
    classes = [
        TestMappingConfig::class,
    ]
)
abstract class AbstractRestTest {

    lateinit var mockMvc: MockMvc

    private var objectMapper: ObjectMapper = TestSimpleJsonObjectMapper.create()

    @Suppress("SameParameterValue")
    private fun acceptContentAuth(
        requestBuilder: MockHttpServletRequestBuilder,
        mediaType: MediaType = MediaType.APPLICATION_JSON,
    ): MockHttpServletRequestBuilder {
        return requestBuilder
            .accept(MediaType.APPLICATION_JSON, MediaType.ALL)
            .header(HEADER_PRIVATE_TOKEN, "Bearer jwtToken")
            .contentType(mediaType)
    }

    private fun acceptAnonymousAuth(requestBuilder: MockHttpServletRequestBuilder): MockHttpServletRequestBuilder {
        return requestBuilder
            .accept(MediaType.APPLICATION_JSON, MediaType.TEXT_PLAIN, MediaType.IMAGE_PNG, MediaType.APPLICATION_PDF)
            .contentType(MediaType.APPLICATION_JSON)
    }

    protected fun performPost(
        url: String,
        body: Any? = null,
        headers: HttpHeaders? = null,
    ): ResultActions = mockMvc.perform(
        generateRequestBuilder(url, body, HttpMethod.POST, headers = headers)
    )

    protected fun performPartPost(
        url: String,
        filePart: MockMultipartFile? = null,
        bodyPart: MockPart? = null,
    ): ResultActions =
        mockMvc.perform(generatePartRequestBuilder(url, filePart, bodyPart))

    protected fun performPatch(
        url: String,
        body: Any? = null,
        headers: HttpHeaders? = null,
    ): ResultActions = mockMvc.perform(
        generateRequestBuilder(url, body, HttpMethod.PATCH, headers = headers)
    )

    protected fun performPut(
        url: String,
        body: Any? = null,
        headers: HttpHeaders? = null,
    ): ResultActions = mockMvc.perform(
        generateRequestBuilder(url, body, HttpMethod.PUT, headers = headers)
    )

    protected fun performGet(
        url: String,
        headers: HttpHeaders? = null,
    ): ResultActions = mockMvc.perform(
        generateRequestBuilder(url, null, HttpMethod.GET, headers = headers)
    )

    protected fun performDelete(
        url: String,
    ): ResultActions = mockMvc.perform(
        generateRequestBuilder(url, null, HttpMethod.DELETE)
    )

    protected fun generateRequestBuilder(
        url: String,
        body: Any?,
        method: HttpMethod = HttpMethod.GET,
        headers: HttpHeaders? = null,
    ): MockHttpServletRequestBuilder {
        val builder = when (method) {
            HttpMethod.GET -> RestDocumentationRequestBuilders.get(url)
            HttpMethod.POST -> RestDocumentationRequestBuilders.post(url)
            HttpMethod.PUT -> RestDocumentationRequestBuilders.put(url)
            HttpMethod.DELETE -> RestDocumentationRequestBuilders.delete(url)
            HttpMethod.PATCH -> RestDocumentationRequestBuilders.patch(url)
            else -> throw RuntimeException("Method not implemented")
        }

        if (body != null) {
            builder.content(objectMapper.writeValueAsString(body))
        }
        if (headers != null) {
            builder.headers(headers)
        }

        return acceptAnonymousAuth(builder)
    }

    private fun generatePartRequestBuilder(
        url: String,
        filePart: MockMultipartFile?,
        bodyPart: MockPart?,
    ): MockMultipartHttpServletRequestBuilder {
        val builder = multipart(url)

        if (filePart != null) {
            builder.file(filePart)
        }
        if (bodyPart != null) {
            builder.part(bodyPart)
        }
        return acceptContentAuth(
            builder,
            mediaType = MediaType.MULTIPART_FORM_DATA,
        ) as MockMultipartHttpServletRequestBuilder
    }

    fun ResultActions.checkStatus(status: HttpStatus): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().`is`(status.value()))
    }

    fun <T> ResultActions.returnsList(clazz: Class<T>): List<T> {
        return this.andReturn().let {
            val constructCollectionType = objectMapper.typeFactory.constructCollectionType(List::class.java, clazz)
            objectMapper.readValue(it.response.contentAsByteArray, constructCollectionType)
        }
    }

    inline fun <reified T : Any> ResultActions.returns(): T {
        return this.andReturn().let {
            `access$objectMapper`.readValue(it.response.contentAsByteArray)
        }
    }

    fun <T> ResultActions.returns(clazz: Class<T>): T {
        return this.andReturn().let {
            objectMapper.readValue(it.response.contentAsByteArray, clazz)
        }
    }

    fun <T> ResultActions.returns(valueTypeRef: TypeReference<T>): T {
        return this.andReturn().let {
            objectMapper.readValue(it.response.contentAsByteArray, valueTypeRef)
        }
    }

    fun ResultActions.expectOk(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isOk)
    }

    fun ResultActions.expectFound(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isFound)
    }

    fun ResultActions.expectForbidden(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isForbidden)
    }

    fun ResultActions.expectUnauthorized(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isUnauthorized)
    }

    fun ResultActions.expect4xx(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().is4xxClientError)
    }

    fun ResultActions.expect5xx(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().is5xxServerError)
    }

    fun ResultActions.expectNoContent(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isNoContent)
    }

    fun ResultActions.expectBadRequest(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isBadRequest)
    }

    fun ResultActions.isNotFound(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isNotFound)
    }

    fun ResultActions.expectConflict(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isConflict)
    }

    fun ResultActions.expectPaymentRequired(): ResultActions {
        return this.andExpect(MockMvcResultMatchers.status().isPaymentRequired)
    }

    @Suppress("PropertyName", "unused")
    @PublishedApi
    internal var `access$objectMapper`: ObjectMapper
        get() = objectMapper
        set(value) {
            objectMapper = value
        }

    protected fun errorResponseFields(): List<FieldDescriptor> {
        return listOf(
            PayloadDocumentation.fieldWithPath("errorCode").type(JsonFieldType.NUMBER).description("Unique error code"),
            PayloadDocumentation.fieldWithPath("errorName").type(JsonFieldType.STRING).description("Short error title"),
            PayloadDocumentation.fieldWithPath("errorMessage").type(JsonFieldType.STRING)
                .description("A detailed message"),
            PayloadDocumentation.fieldWithPath("time").type(JsonFieldType.STRING).description("Timestamp of error")
        )
    }

    companion object {
        const val HEADER_PRIVATE_TOKEN = "Authorization"
    }
}
