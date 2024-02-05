package at.sensatech.openfastlane.testcommons

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.DomainModule
import at.sensatech.openfastlane.domain.repositories.RepositoriesClasses
import at.sensatech.openfastlane.testcontainers.MongoDbTestContainerConfig
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.test.context.*
import org.testcontainers.junit.jupiter.Testcontainers

@TestPropertySource("classpath:application-test-data.yml")
@DataMongoTest(
    properties = [
        "spring.data.mongodb.host=localhost",
        "spring.data.mongodb.port=27017",
    ]
)
@ActiveProfiles(ApplicationProfiles.TEST)
@ComponentScan(basePackageClasses = [RepositoriesClasses::class])
@ContextConfiguration(classes = [DomainModule::class])
@EnableAutoConfiguration
@Testcontainers
@MongoDbTestContainerConfig
abstract class AbstractMongoDbServiceTest : AbstractMockedServiceTest() {

    companion object {
        @Suppress("unused")
        @JvmStatic
        @DynamicPropertySource
        fun configureMailHost(registry: DynamicPropertyRegistry) {
            MongoDbTestContainerConfig.updateDynamicPropertySource(registry)
        }
    }

    @Autowired
    var mongoTemplate: MongoTemplate? = null

}
