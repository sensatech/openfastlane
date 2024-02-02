package at.sensatech.openfastlane.domain.repositories

import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Configuration
import org.springframework.test.context.DynamicPropertyRegistry
import org.testcontainers.containers.GenericContainer
import org.testcontainers.containers.Network
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.utility.DockerImageName


@Configuration
annotation class MongoDbTestContainerConfig {

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)

        @Container
        val mongoDbContainer: GenericContainer<*> = ContainerHelper.createMongoDbContainer()

        init {
            mongoDbContainer.start()
        }

        fun updateDynamicPropertySource(registry: DynamicPropertyRegistry) {
            mongoDbContainer.start()
            log.info("AbstractRepositoryTest mongoContainer=${mongoDbContainer} isHealthy")
            val firstMappedPort = mongoDbContainer.firstMappedPort
            log.info("AbstractRepositoryTest mongo host=${mongoDbContainer.host} port=$firstMappedPort")

            registry.add("spring.data.mongodb.host", mongoDbContainer::getHost)
            registry.add("spring.data.mongodb.port", mongoDbContainer::getFirstMappedPort)
        }
    }
}

object ContainerHelper {

    val mongoImage = DockerImageName.parse("mongo:latest")
    val network by lazy { Network.newNetwork() }


    fun createMongoDbContainer() =
        GenericContainer(mongoImage)
            .withExposedPorts(27017)

}
