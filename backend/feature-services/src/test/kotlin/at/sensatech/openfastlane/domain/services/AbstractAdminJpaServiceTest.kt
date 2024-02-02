package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.DomainModule
import at.sensatech.openfastlane.domain.config.OflConfiguration
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource

@TestPropertySource("classpath:application-test-data.yml")
@DataJpaTest
@ActiveProfiles(ApplicationProfiles.TEST)
@ComponentScan(basePackageClasses = [DomainModule::class])
@ContextConfiguration(classes = [OflConfiguration::class])
abstract class AbstractIntegrationServiceTest : AbstractMockedServiceTest() {


}
