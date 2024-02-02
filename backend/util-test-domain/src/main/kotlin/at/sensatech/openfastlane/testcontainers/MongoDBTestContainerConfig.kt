package at.sensatech.openfastlane.testcontainers

import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Configuration
import org.springframework.data.mongodb.repository.config.EnableMongoRepositories
import org.testcontainers.containers.GenericContainer
import org.testcontainers.containers.Network
import org.testcontainers.junit.jupiter.Container
import org.testcontainers.utility.DockerImageName


//@Configuration
//@EnableMongoRepositories
//class MongoDBTestContainerConfig {
//
//    companion object {
//        private val log = LoggerFactory.getLogger(this::class.java)
//
//        @Container
//        val mongoDBContainer = ContainerHelper.createMongoDbContainer()
//
//        init {
////            mongoDBContainer.start()
//            val mappedPort = mongoDBContainer.getMappedPort(27017)
////            System.setProperty("spring.data.mongodb.port", mappedPort.toString())
//            log.info("MongoDBTestContainerConfig MongoDB container started on port {}", mappedPort)
//        }
//    }
//}
object ContainerHelper {

    val mongoImage = DockerImageName.parse("mongo:latest");
    val network by lazy { Network.newNetwork() }
    fun createEmailContainer(): GenericContainer<*> {
        return GenericContainer("mailhog/mailhog")
            .withExposedPorts(1025, 8025)
            .withNetwork(network)
            .withNetworkAliases("mail")
    }

    fun createMongoDbContainer(): GenericContainer<*> {
        return GenericContainer(mongoImage)
            .withEnv("MONGO_INITDB_ROOT_USERNAME", "testuser")
            .withEnv("MONGO_INITDB_ROOT_PASSWORD", "testpassword")
            .withEnv("MONGO_INITDB_DATABASE", "mongotest")
            .withExposedPorts(27017)
    }
}