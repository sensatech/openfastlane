package at.sensatech.openfastlane.domain.entitlements

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType.CHECKBOX
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType.FLOAT
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType.INTEGER
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType.OPTIONS
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType.TEXT
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.EntitlementValue
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
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
import java.time.ZonedDateTime

class EntitlementsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    @Autowired
    lateinit var campaignRepository: CampaignRepository

    @Autowired
    lateinit var personRepository: PersonRepository

    lateinit var subject: EntitlementsServiceImpl

    final val campaigns = listOf(
        Mocks.mockCampaign(name = "campaign1"),
        Mocks.mockCampaign(name = "campaign1"),
    )
    final val causes = listOf(
        Mocks.mockEntitlementCause(name = "cause1", campaignId = campaigns[0].id),
        Mocks.mockEntitlementCause(name = "cause2", campaignId = campaigns[1].id),
    )
    final val firstCause = causes.first()

    private final val entitlements = persons.map {
        Mocks.mockEntitlement(it.id, entitlementCauseId = firstCause.id, campaignId = campaigns[0].id)
    }

    val firstEntitlement = entitlements.first()

    @BeforeEach
    fun beforeEach() {
        subject = EntitlementsServiceImpl(entitlementRepository, causeRepository, campaignRepository, personRepository)
        personRepository.deleteAll()
        personRepository.saveAll(persons)
        campaignRepository.saveAll(campaigns)
        causeRepository.saveAll(causes)

        entitlementRepository.saveAll(entitlements)
    }

    val createRequest = CreateEntitlement(
        personId = firstPerson.id,
        entitlementCauseId = causes[1].id,
        values = emptyList()
    )

    @Nested
    inner class createEntitlement {

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
                subject.createEntitlement(reader, createRequest)
            }
        }

        @Test
        fun `createEntitlement should be allowed for MANAGER`() {
            val result = subject.createEntitlement(manager, createRequest)
            assertThat(result).isNotNull
        }

        @Test
        fun `createEntitlement should save Entitlement in storage`() {
            val result = subject.createEntitlement(manager, createRequest)

            val entitlement = entitlementRepository.findByIdOrNull(result.id)
            assertThat(entitlement).isNotNull
            assertThat(entitlement).isEqualTo(result)
        }

        @Test
        fun `createEntitlement should return error when already has one for same EntitlementCauseId`() {
            subject.createEntitlement(manager, createRequest)
            assertThrows<EntitlementsError.PersonEntitlementAlreadyExists> {
                subject.createEntitlement(manager, createRequest)
            }
        }

        @Test
        fun `createEntitlement should create a Value for each Value of EntitlementCause with correct type`() {
            val result = subject.createEntitlement(manager, createRequest)
            val cause = causes[1]
            assertThat(result.values).hasSize(cause.criterias.size)
            cause.criterias.forEach {
                assertThat(result.values).contains(EntitlementValue(it.id, it.type, ""))
            }
        }

        @Test
        fun `createEntitlement should append CREATED to the audit log`() {
            val result = subject.createEntitlement(manager, createRequest)
            assertThat(result).isNotNull
            assertThat(result.audit).isNotEmpty
            assertThat(result.audit).hasSize(1)

            val auditItem = result.audit[0]
            assertThat(auditItem.user).isEqualTo(manager.username)
            assertThat(auditItem.action).isEqualTo("CREATED")
        }
    }

    @Nested
    inner class updateEntitlement {
        val updateEntitlement = UpdateEntitlement(
            values = listOf(
                EntitlementValue(firstCause.criterias[0].id, TEXT, "value"),
                EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"),
                EntitlementValue(firstCause.criterias[2].id, INTEGER, "5"),
                EntitlementValue(firstCause.criterias[3].id, OPTIONS, "option1"),
                EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"),
            )
        )

        @Test
        fun `updateEntitlement should fail for unknown entitlementCauseId`() {
            assertThrows<EntitlementsError.NoEntitlementFound> {
                subject.updateEntitlement(manager, newId(), updateEntitlement)
            }
        }

        @Test
        fun `updateEntitlement should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                subject.updateEntitlement(reader, firstEntitlement.id, updateEntitlement)
            }
        }

        @Test
        fun `updateEntitlement should be allowed for MANAGER`() {
            val result = subject.updateEntitlement(manager, firstEntitlement.id, updateEntitlement)
            assertThat(result).isNotNull
        }

        @Test
        fun `updateEntitlement should save Entitlement in storage`() {
            val result = subject.updateEntitlement(manager, firstEntitlement.id, updateEntitlement)

            val entitlement = entitlementRepository.findByIdOrNull(result.id)
            assertThat(entitlement).isNotNull
            assertThat(entitlement).isEqualTo(result)
            assertThat(entitlement!!.updatedAt).isAfter(firstEntitlement.updatedAt)
            assertThat(entitlement.createdAt.withNano(0)).isEqualTo(firstEntitlement.createdAt.withNano(0))
        }

        @Test
        fun `updateEntitlement should update the EntitlementState`() {
            val result = subject.updateEntitlement(manager, firstEntitlement.id, updateEntitlement)
            assertThat(result.status).isEqualTo(EntitlementStatus.VALID)
        }

        @Test
        fun `updateEntitlement should validate the values and store EntitlementStatus`() {
            val result = subject.updateEntitlement(manager, firstEntitlement.id, UpdateEntitlement(listOf()))
            assertThat(result.status).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `updateEntitlement should update its values`() {
            val created = subject.createEntitlement(manager, createRequest)
            val request = UpdateEntitlement(
                values = listOf(
                    EntitlementValue(created.values[0].criteriaId, TEXT, "value"),
                    EntitlementValue(created.values[1].criteriaId, CHECKBOX, "true"),
                    EntitlementValue(created.values[2].criteriaId, INTEGER, "5"),
                    EntitlementValue(created.values[3].criteriaId, OPTIONS, "option1"),
                    EntitlementValue(created.values[4].criteriaId, FLOAT, "5.6"),
                )
            )
            val result = subject.updateEntitlement(manager, created.id, request)

            assertThat(result.values).isNotEmpty()
            assertThat(result.values).containsExactly(
                EntitlementValue(created.values[0].criteriaId, TEXT, "value"),
                EntitlementValue(created.values[1].criteriaId, CHECKBOX, "true"),
                EntitlementValue(created.values[2].criteriaId, INTEGER, "5"),
                EntitlementValue(created.values[3].criteriaId, OPTIONS, "option1"),
                EntitlementValue(created.values[4].criteriaId, FLOAT, "5.6"),
            )
        }

        @Test
        fun `updateEntitlement should overwrite values and set EntitlementStatus`() {
            val created = subject.createEntitlement(manager, createRequest)

            subject.updateEntitlement(
                manager,
                created.id,
                UpdateEntitlement(
                    values = listOf(
                        EntitlementValue(created.values[0].criteriaId, TEXT, "value"),
                        EntitlementValue(created.values[1].criteriaId, CHECKBOX, "true"),
                        EntitlementValue(created.values[2].criteriaId, INTEGER, "5"),
                        EntitlementValue(created.values[3].criteriaId, OPTIONS, "option1"),
                        EntitlementValue(created.values[4].criteriaId, FLOAT, "5.6"),
                    )
                )
            )

            val reset = subject.updateEntitlement(
                manager,
                created.id,
                UpdateEntitlement(
                    values = listOf(
                        EntitlementValue(created.values[0].criteriaId, TEXT, ""),
                        EntitlementValue(created.values[1].criteriaId, CHECKBOX, ""),
                        EntitlementValue(created.values[2].criteriaId, INTEGER, ""),
                        EntitlementValue(created.values[3].criteriaId, OPTIONS, ""),
                        EntitlementValue(created.values[4].criteriaId, FLOAT, ""),
                    )
                )
            )

            assertThat(reset.values).isNotEmpty()
            assertThat(reset.values).containsExactly(
                EntitlementValue(created.values[0].criteriaId, TEXT, ""),
                EntitlementValue(created.values[1].criteriaId, CHECKBOX, ""),
                EntitlementValue(created.values[2].criteriaId, INTEGER, ""),
                EntitlementValue(created.values[3].criteriaId, OPTIONS, ""),
                EntitlementValue(created.values[4].criteriaId, FLOAT, ""),
            )
        }

        @Test
        fun `updateEntitlement must not delete the values`() {
            val created = subject.createEntitlement(manager, createRequest)
            val request = UpdateEntitlement(values = listOf())
            val result = subject.updateEntitlement(manager, created.id, request)

            assertThat(result.values).isNotEmpty()
            assertThat(result.values).containsExactly(*created.values.toTypedArray())
        }

        @Test
        fun `updateEntitlement should patch the Entitlement and update values separately`() {
            val result = subject.updateEntitlement(
                manager,
                firstEntitlement.id,
                UpdateEntitlement(listOf(EntitlementValue(firstCause.criterias[0].id, TEXT, "newValue")))
            )
            assertThat(result.values).isNotEmpty()
            assertThat(result.values.find { it.criteriaId == firstCause.criterias[0].id }!!.value).isEqualTo("newValue")
        }

        @Test
        fun `updateEntitlement should append UPDATE to the audit log`() {
            subject.updateEntitlement(
                manager,
                firstEntitlement.id,
                UpdateEntitlement(
                    listOf(EntitlementValue(firstCause.criterias[0].id, TEXT, "newValue"))
                )
            )
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)
            assertThat(entitlement).isNotNull
            assertThat(entitlement!!.audit).isNotEmpty
            assertThat(entitlement.audit).hasSize(1)

            val auditItem = entitlement.audit[0]
            assertThat(auditItem.user).isEqualTo(manager.username)
            assertThat(auditItem.action).isEqualTo("UPDATED")
        }
    }

    @Nested
    inner class mergeValues {

        val baseValues = listOf(
            EntitlementValue("key1", TEXT, "value"),
            EntitlementValue("key2", CHECKBOX, "true"),
        )

        @Test
        fun `mergeValues should contain all values of first parameter`() {
            val result = subject.mergeValues(baseValues, listOf())
            assertThat(result).isNotNull
            assertThat(result).hasSize(2)
            assertThat(result).containsAll(baseValues)
        }

        @Test
        fun `mergeValues should replace all matching values with second param`() {
            val result = subject.mergeValues(
                baseValues,
                listOf(
                    EntitlementValue("key1", TEXT, "new"),
                )
            )
            assertThat(result).isNotNull
            assertThat(result).hasSize(2)
            assertThat(result).containsExactly(
                EntitlementValue("key1", TEXT, "new"),
                EntitlementValue("key2", CHECKBOX, "true"),
            )
        }

        @Test
        fun `mergeValues should not add unknown parameters`() {
            val result = subject.mergeValues(
                baseValues,
                listOf(
                    EntitlementValue("key3", TEXT, "new"),
                )
            )
            assertThat(result).isNotNull
            assertThat(result).hasSize(2)
            assertThat(result).containsExactly(
                EntitlementValue("key1", TEXT, "value"),
                EntitlementValue("key2", CHECKBOX, "true"),
            )
        }

        @Test
        fun `mergeValues should not add wrong type parameters ignoring the validity`() {
            val result = subject.mergeValues(
                baseValues,
                listOf(
                    EntitlementValue("key2", TEXT, "blabla"),
                )
            )
            assertThat(result).isNotNull
            assertThat(result).hasSize(2)
            assertThat(result).containsExactly(
                EntitlementValue("key1", TEXT, "value"),
                EntitlementValue("key2", CHECKBOX, "blabla"),
            )
        }
    }

    @Nested
    inner class ValidateEntitlement {
        @Test
        fun `validateEntitlement should be allowed for READER`() {
            val result = subject.validateEntitlement(reader, firstEntitlement)
            assertThat(result).isNotNull
            assertThat(result).isInstanceOf(EntitlementStatus::class.java)
        }

        @Test
        fun `validateEntitlement should return PENDING if entitlement was saved but confirmedAt in future`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue("key", TEXT, "value"))
                confirmedAt = ZonedDateTime.now().plusDays(1)
                expiresAt = null
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.PENDING)
        }

        @Test
        fun `validateEntitlement should return VALID if all values are set (not empty) and all Cause Criterias are met`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "45"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, "option1"))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.VALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when values of Cause are missing`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "45"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when values are empty`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, ""))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "45"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, ""))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when INTEGER values are invalid`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "parseError"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, "option1"))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when FLOAT values are not parseable`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "5"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, "option1"))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "parseError"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when CHECKBOX values are not parseable`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "parseError"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "5"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, "option1"))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return INVALID when OPTIONS values are invalid`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue(firstCause.criterias[0].id, TEXT, "value"))
                values.add(EntitlementValue(firstCause.criterias[1].id, CHECKBOX, "true"))
                values.add(EntitlementValue(firstCause.criterias[2].id, INTEGER, "5"))
                values.add(EntitlementValue(firstCause.criterias[3].id, OPTIONS, "wrong option"))
                values.add(EntitlementValue(firstCause.criterias[4].id, FLOAT, "5.6"))
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.INVALID)
        }

        @Test
        fun `validateEntitlement should return EXPIRED when expiredAt is in the past`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                expiresAt = ZonedDateTime.now().minusDays(1)
            }
            val result = subject.validateEntitlement(reader, entitlement)
            assertThat(result).isEqualTo(EntitlementStatus.EXPIRED)
        }

        @Test
        fun `validateEntitlement must not update or change underlying entity`() {
            val entitlement = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue("key", TEXT, "value"))
            }
            subject.validateEntitlement(reader, entitlement)
            val entitlement2 = entitlementRepository.findByIdOrNull(firstEntitlement.id)!!.apply {
                values.add(EntitlementValue("key", TEXT, "value"))
            }
            assertThat(entitlement).isEqualTo(entitlement2)
            assertThat(entitlement2.updatedAt).isEqualTo(entitlement.updatedAt)
        }
    }

    @Nested
    inner class checkCriteria {

        val criterias = firstCause.criterias

        @Test
        fun `checkCriteria should return false when TEXT values are empty`() {
            testCheckCriteria(criterias[0], EntitlementValue(criterias[0].id, TEXT, ""), false)
            testCheckCriteria(criterias[0], EntitlementValue(criterias[0].id, TEXT, "value"), true)
        }

        private fun testCheckCriteria(criterion: EntitlementCriteria, value: EntitlementValue, expected: Boolean) {
            assertThat(subject.checkCriteria(criterion, value)).isEqualTo(expected)
        }

        @Test
        fun `checkCriteria should return false when CHECKBOX values are invalid`() {
            testCheckCriteria(criterias[1], EntitlementValue(criterias[1].id, CHECKBOX, "value"), false)
            testCheckCriteria(criterias[1], EntitlementValue(criterias[1].id, CHECKBOX, ""), false)
            testCheckCriteria(criterias[1], EntitlementValue(criterias[1].id, CHECKBOX, "true"), true)
            testCheckCriteria(criterias[1], EntitlementValue(criterias[1].id, CHECKBOX, "false"), true)
        }

        @Test
        fun `checkCriteria should return false when INTEGER values are invalid`() {
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, ""), false)
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, "value"), false)
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, "another text 54"), false)
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, "5"), true)
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, "5 "), true)
            testCheckCriteria(criterias[2], EntitlementValue(criterias[2].id, INTEGER, " 5 "), true)
        }

        @Test
        fun `checkCriteria should return false when OPTIONS values are invalid`() {

            testCheckCriteria(criterias[3], EntitlementValue(criterias[3].id, OPTIONS, " "), false)
            testCheckCriteria(criterias[3], EntitlementValue(criterias[3].id, OPTIONS, "wrong option"), false)
            testCheckCriteria(criterias[3], EntitlementValue(criterias[3].id, OPTIONS, "option1"), true)
            testCheckCriteria(criterias[3], EntitlementValue(criterias[3].id, OPTIONS, "option1"), true)
        }

        @Test
        fun `checkCriteria should return false when FLOAT values are invalid`() {

            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, "value"), false)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " "), false)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " asd"), false)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " asd"), false)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, "5"), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, "5 "), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " 5 "), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, "5.0"), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, "5.6 "), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " 5.78 "), true)
            testCheckCriteria(criterias[4], EntitlementValue(criterias[4].id, FLOAT, " 5.78,0 "), false)
        }
    }

    @Nested
    inner class extendEntitlement {
        @Test
        fun `extendEntitlement should be allowed for MANAGER`() {
            val result = subject.extendEntitlement(manager, firstEntitlement.id)
            assertThat(result).isNotNull
        }

        @Test
        fun `extendEntitlement should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                val result = subject.extendEntitlement(reader, firstEntitlement.id)
                assertThat(result).isNotNull
            }
        }

        @Test
        fun `extendEntitlement should extend for the time of ENtitlementCause Period`() {
            assertThrows<UserError.InsufficientRights> {
                val result = subject.extendEntitlement(reader, firstEntitlement.id)
                assertThat(result).isNotNull
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
