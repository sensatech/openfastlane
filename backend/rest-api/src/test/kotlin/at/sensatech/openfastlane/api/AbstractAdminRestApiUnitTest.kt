package at.sensatech.openfastlane.api

import at.sensatech.openfastlane.api.testcommons.TestAdminDetailsService
import at.sensatech.openfastlane.api.testcommons.TestSecurityConfiguration
import at.sensatech.openfastlane.api.testcommons.TestWebConfigurer
import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.testcommons.AbstractRestTest
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.extension.ExtendWith
import org.springframework.restdocs.RestDocumentationContextProvider
import org.springframework.restdocs.RestDocumentationExtension
import org.springframework.restdocs.mockmvc.MockMvcRestDocumentation
import org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.documentationConfiguration
import org.springframework.restdocs.operation.preprocess.Preprocessors
import org.springframework.restdocs.operation.preprocess.Preprocessors.modifyHeaders
import org.springframework.restdocs.snippet.Snippet
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers.springSecurity
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.junit.jupiter.SpringExtension
import org.springframework.test.web.servlet.ResultActions
import org.springframework.test.web.servlet.setup.DefaultMockMvcBuilder
import org.springframework.test.web.servlet.setup.MockMvcBuilders
import org.springframework.web.context.WebApplicationContext

@ExtendWith(value = [RestDocumentationExtension::class, SpringExtension::class])
@ActiveProfiles(ApplicationProfiles.TEST)
@ContextConfiguration(
        classes = [
            TestSecurityConfiguration::class,
            TestAdminDetailsService::class,
            TestWebConfigurer::class]
)
internal abstract class AbstractAdminRestApiUnitTest : AbstractRestTest() {

    val testWebConfigurer = TestWebConfigurer()

    @BeforeEach
    fun setUp(
            webApplicationContext: WebApplicationContext,
            restDocumentation: RestDocumentationContextProvider,
    ) {
        this.mockMvc = MockMvcBuilders
                .webAppContextSetup(webApplicationContext)
                .apply<DefaultMockMvcBuilder>(springSecurity())
                .apply<DefaultMockMvcBuilder>(
                        documentationConfiguration(restDocumentation)
                                .operationPreprocessors()
                                .withRequestDefaults(
                                        modifyHeaders().removeMatching(HEADER_PRIVATE_TOKEN),
                                        Preprocessors.prettyPrint(),
                                )
                                .withResponseDefaults(Preprocessors.prettyPrint())
                ).build()
    }

    fun ResultActions.document(name: String, vararg snippets: Snippet): ResultActions {
        return this.andDo(MockMvcRestDocumentation.document(name, *snippets))
    }

}
