package at.sensatech.openfastlane.testcommons

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.DomainModule
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource
import org.testcontainers.junit.jupiter.Testcontainers

@TestPropertySource("classpath:application-test-data.yml")
@Testcontainers
@DataMongoTest
@ActiveProfiles(ApplicationProfiles.TEST)
@ComponentScan(basePackageClasses = [DomainModule::class])
@ContextConfiguration(classes = [])
@SpringBootTest(
    properties = [
        "spring.data.mongodb.host=mongo",
        "spring.data.mongodb.port=27017"
    ]
)
abstract class AbstractDataServiceTest {


//    companion object {
//        private val log = LoggerFactory.getLogger(this::class.java)
//
//        @Container
//        private val mongoContainer = ContainerHelper.createMongoDbContainer()
//
//        @Suppress("unused")
//        @JvmStatic
//        @DynamicPropertySource
//        fun configureMailHost(registry: DynamicPropertyRegistry) {
//            registry.add("spring.data.mongodb.host", mongoContainer::getHost)
//            registry.add("spring.data.mongodb.port", mongoContainer::getFirstMappedPort)
//            log.info("AbstractDataServiceTest mongo host=${mongoContainer.host} port=${mongoContainer.firstMappedPort}")
//        }
//    }

    @Autowired
    lateinit var mongoTemplate: MongoTemplate

}
