package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.UserError
import at.sensatech.openfastlane.mocks.Mocks
import at.sensatech.openfastlane.testcommons.AbstractMongoDbServiceTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.repository.findByIdOrNull

class EntitlementsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    @Autowired
    lateinit var personRepository: PersonRepository

    lateinit var subject: EntitlementsServiceImpl

    final val causes = listOf(
        Mocks.mockEntitlementCause(name = "cause1"),
        Mocks.mockEntitlementCause(name = "cause2"),
    )

    final val entitlements = persons.map {
        Mocks.mockEntitlement(it.id)
    }

    val firstEntitlement = entitlements.first()
    val firstCause = causes.first()

    @BeforeEach
    fun beforeEach() {
        subject = EntitlementsServiceImpl(entitlementRepository, causeRepository, personRepository)
        personRepository.deleteAll()
        personRepository.saveAll(persons)
        entitlementRepository.saveAll(entitlements)
        causeRepository.saveAll(causes)
    }

    @Nested
    inner class createEntitlement {
        val request = CreateEntitlement(
            personId = firstPerson.id,
            entitlementCauseId = firstCause.id,
            values = emptyList()
        )

        @Test
        fun `createEntitlement should fail for unknown entitlementCauseId`() {
            assertThrows<EntitlementsError.NoEntitlementCauseFound> {
                subject.createEntitlement(
                    manager,
                    CreateEntitlement(
                        personId = firstPerson.id,
                        entitlementCauseId = newId(),
                        values = emptyList()
                    )
                )
            }
        }

        @Test
        fun `createEntitlement should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                subject.createEntitlement(reader, request)
            }
        }

        @Test
        fun `createEntitlement should be allowed for MANAGER`() {
            val result = subject.createEntitlement(manager, request)
            assertThat(result).isNotNull
        }

        @Test
        fun `createEntitlement should save Entitlement in storage`() {
            val result = subject.createEntitlement(manager, request)

            val entitlement = entitlementRepository.findByIdOrNull(result.id)
            assertThat(entitlement).isNotNull
            assertThat(entitlement).isEqualTo(result)
        }

        @Test
        fun `createEntitlement should return error when already has one for same EntitlementCauseId`() {
            subject.createEntitlement(manager, request)
            assertThrows<EntitlementsError.PersonEntitlementAlreadyExists> {
                subject.createEntitlement(manager, request)
            }
        }
    }

    @Nested
    inner class listAllEntitlements {
        @Test
        fun `listAllEntitlements should be allowed for READER`() {
            val persons = subject.listAllEntitlements(reader)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getEntitlement {
        @Test
        fun `getEntitlement should be allowed for READER`() {
            val persons = subject.getEntitlement(reader, firstEntitlement.id)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class entitlementCauses {
        @Test
        fun `listAllEntitlementCauses should be allowed for READER`() {
            val causes = subject.listAllEntitlementCauses(reader)
            assertThat(causes).isNotNull
        }

        @Test
        fun `getEntitlementCause should be allowed for READER`() {
            val cause = subject.getEntitlementCause(reader, firstCause.id)
            assertThat(cause).isNotNull
        }
    }
}
