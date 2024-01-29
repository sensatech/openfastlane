import at.sensatech.openfastlane.common.ApplicationProfiles
import at.sensatech.openfastlane.domain.DomainModule
import at.sensatech.openfastlane.domain.repositories.RepositoriesClasses
import io.zonky.test.db.AutoConfigureEmbeddedDatabase
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.boot.autoconfigure.EnableAutoConfiguration
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.dao.DataIntegrityViolationException
import org.springframework.data.repository.CrudRepository
import org.springframework.data.repository.findByIdOrNull
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.context.ContextConfiguration
import org.springframework.test.context.TestPropertySource
import org.springframework.transaction.annotation.Isolation
import org.springframework.transaction.annotation.Propagation
import org.springframework.transaction.annotation.Transactional

@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
@Test
@Transactional(
        isolation = Isolation.READ_UNCOMMITTED,
        propagation = Propagation.NEVER,
)
annotation class TestWithJpaCommit

@TestPropertySource("classpath:application-test-jpa.yml")
@DataJpaTest
@ActiveProfiles(ApplicationProfiles.TEST)
@ComponentScan(basePackageClasses = [RepositoriesClasses::class])
@ContextConfiguration(classes = [DomainModule::class])
@EnableAutoConfiguration
@AutoConfigureEmbeddedDatabase(
        type = AutoConfigureEmbeddedDatabase.DatabaseType.POSTGRES,
        refresh = AutoConfigureEmbeddedDatabase.RefreshMode.AFTER_EACH_TEST_METHOD
)
internal abstract class AbstractRepositoryTest<ENTITY_T, ID_TYPE, RepositoryT : CrudRepository<ENTITY_T, ID_TYPE>> {

    abstract val repository: RepositoryT

    private var lastId = 1

    fun createDefaultEntity(): ENTITY_T = createDefaultEntityPair(++lastId).second

    abstract fun createDefaultEntityPair(id: Int = ++lastId): Pair<ID_TYPE, ENTITY_T>
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
    fun `update should store the changed entity`() {
        val (_, entity) = createDefaultEntityPair()
        val saved = repository.save(entity)
        val copy = changeEntity(saved)
        val updated = repository.save(copy)
        assertThat(updated).isNotNull
    }

    @Test
    fun `delete should remove an entity from database`() {
        val (_, entity) = createDefaultEntityPair()
        val saved = repository.save(entity)
        repository.delete(saved)
        assertThat(saved).isNotNull
    }

}
