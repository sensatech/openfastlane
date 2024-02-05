package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.DomainModule
import org.assertj.core.api.Assertions.assertThat
import org.bson.types.ObjectId
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.boot.test.autoconfigure.data.mongo.DataMongoTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.data.mongodb.core.MongoTemplate
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.data.repository.findByIdOrNull
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.DynamicPropertyRegistry
import org.springframework.test.context.DynamicPropertySource
import org.springframework.test.context.TestPropertySource
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
internal abstract class AbstractRepositoryTest<ENTITY_T, ID_TYPE, RepositoryT : MongoRepository<ENTITY_T, ID_TYPE>> {

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

    abstract val repository: RepositoryT

    private var lastId = 1

    fun createDefaultEntity(id: String = ObjectId.get().toString()): ENTITY_T = createDefaultEntityPair(id).second

    abstract fun createDefaultEntityPair(id: String = ObjectId.get().toString()): Pair<ID_TYPE, ENTITY_T>

    abstract fun changeEntity(entity: ENTITY_T): ENTITY_T

    fun cleanTables() {
        repository.deleteAll()
    }

    protected fun violatesConstraints(f: () -> Unit) {
        assertThrows<DataIntegrityViolationException> { f.invoke() }
    }

    @BeforeEach
    fun beforeEach() {
        cleanTables()
    }

    @Test
    fun `save should store an entity`() {
        val (id, entity) = createDefaultEntityPair()
        assertThat(repository.findByIdOrNull(id)).isNull()
        repository.save(entity)
        assertThat(repository.findByIdOrNull(id)).isNotNull
    }

    @Test
    fun `save should return a stored entity`() {
        val (id, entity) = createDefaultEntityPair()
        assertThat(repository.findByIdOrNull(id)).isNull()
        val saved = repository.save(entity)
        assertThat(saved).isNotNull
        assertThat(repository.findByIdOrNull(id)).isNotNull
    }

    @Test
    fun `save should support mutation without duplicates`() {
        val (id, entity) = createDefaultEntityPair()
        val saved = repository.save(entity)
        val changed = changeEntity(saved)
        val savedAgain = repository.save(changed)

        assertThat(saved).isNotNull
        assertThat(savedAgain).isNotNull
        val findByIdOrNull = repository.findByIdOrNull(id)
        assertThat(findByIdOrNull).isNotNull
    }

    @Test
    fun `update should store the changed entity`() {
        val (id, entity) = createDefaultEntityPair()
        val saved = repository.save(entity)
        val copy = changeEntity(saved)
        val updated = repository.save(copy)
        assertThat(updated).isNotNull

        val findByIdOrNull = repository.findByIdOrNull(id)
        assertThat(findByIdOrNull).isNotNull
    }

    @Test
    fun `delete should remove an entity from database`() {
        val (id, entity) = createDefaultEntityPair()
        val saved = repository.save(entity)
        repository.delete(saved)
        val findByIdOrNull = repository.findByIdOrNull(id)
        assertThat(findByIdOrNull).isNull()
    }
}
