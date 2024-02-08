package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.domain.entitlements.CreateEntitlement
import at.sensatech.openfastlane.domain.entitlements.EntitlementsServiceImpl
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

class EntitlmentsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

    @Autowired
    lateinit var personRepository: PersonRepository

    lateinit var subject: EntitlementsServiceImpl

    final val entitlements = persons.map {
        Mocks.mockEntitlement(it.id)
    }
    val firstEntitlement = entitlements.first()

    @BeforeEach
    fun beforeEach() {
        subject = EntitlementsServiceImpl(entitlementRepository, personRepository)
        personRepository.deleteAll()
        personRepository.saveAll(persons)
        entitlementRepository.saveAll(entitlements)
    }

    @Nested
    inner class createEntitlement {
        val request = CreateEntitlement(
            personId = firstPerson.id,
            entitlementCauseId = "causeId",
            values = emptyList()
        )

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
            assertThrows<IllegalArgumentException> {
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
}
