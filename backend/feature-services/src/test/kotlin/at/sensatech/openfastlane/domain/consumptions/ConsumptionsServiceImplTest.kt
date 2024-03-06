package at.sensatech.openfastlane.domain.consumptions

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.assertDateTime
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionPossibility
import at.sensatech.openfastlane.domain.cosumptions.ConsumptionsError
import at.sensatech.openfastlane.domain.entitlements.EntitlementsError
import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementStatus
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.persons.PersonsError
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.ConsumptionRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementRepository
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.mocks.Mocks
import at.sensatech.openfastlane.testcommons.AbstractMongoDbServiceTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.repository.findByIdOrNull
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZonedDateTime

class ConsumptionsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

    @Autowired
    lateinit var causeRepository: EntitlementCauseRepository

    @Autowired
    lateinit var campaignRepository: CampaignRepository

    @Autowired
    lateinit var personRepository: PersonRepository

    @Autowired
    lateinit var consumptionRepository: ConsumptionRepository

    lateinit var subject: ConsumptionsServiceImpl

    private final val campaigns = listOf(
        Mocks.mockCampaign(name = "campaign1"),
        Mocks.mockCampaign(name = "campaign1"),
    )
    private final val causes = listOf(
        Mocks.mockEntitlementCause(name = "cause1", campaignId = campaigns[0].id),
        Mocks.mockEntitlementCause(name = "cause2", campaignId = campaigns[1].id),
    )

    val day1: ZonedDateTime = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
    val day2: ZonedDateTime = ZonedDateTime.of(2024, 1, 2, 12, 0, 0, 0, ZoneId.systemDefault())
    val day3: ZonedDateTime = ZonedDateTime.of(2024, 1, 3, 12, 0, 0, 0, ZoneId.systemDefault())

    lateinit var entitlements: List<Entitlement>
    lateinit var items1: List<Consumption>
    lateinit var items2: List<Consumption>
    lateinit var items3: List<Consumption>

    @BeforeEach
    fun beforeEach() {
        subject = ConsumptionsServiceImpl(
            entitlementRepository,
            causeRepository,
            campaignRepository,
            personRepository,
            consumptionRepository
        )
        personRepository.deleteAll()
        campaignRepository.deleteAll()
        causeRepository.deleteAll()
        entitlementRepository.deleteAll()
        consumptionRepository.deleteAll()
    }

    @Nested
    inner class CheckConsumptionPossibility {

        @BeforeEach
        fun beforeEach() {
            personRepository.saveAll(persons)
            campaignRepository.saveAll(campaigns)
            causeRepository.saveAll(causes)

            entitlements = persons.map {
                entitlementRepository.save(Mocks.mockEntitlement(it.id, causes[0].id, campaigns[0].id))
            }
        }

        @Test
        fun `checkConsumptionPossibility should throw for missing person `() {
            assertThrows<PersonsError.NotFoundException> {
                subject.checkConsumptionPossibility(manager, newId(), campaigns.first().id)
            }
        }

        @Test
        fun `checkConsumptionPossibility should throw for missing campaign `() {
            assertThrows<EntitlementsError.NoCampaignFound> {
                subject.checkConsumptionPossibility(manager, firstPerson.id, newId())
            }
        }

        @Test
        fun `checkConsumptionPossibility should return REQUEST_INVALID for errors`() {
            entitlementRepository.deleteAll()
            val result = subject.checkConsumptionPossibility(manager, firstPerson.id, campaigns.first().id)
            assertThat(result).isEqualTo(ConsumptionPossibility.REQUEST_INVALID)
        }

        @Test
        fun `checkConsumptionPossibility should return ENTITLEMENT_INVALID when entitlement is invalid`() {
            entitlementRepository.save(
                entitlements.first().apply {
                    status = EntitlementStatus.INVALID
                }
            )

            val result = subject.checkConsumptionPossibility(manager, firstPerson.id, campaigns.first().id)
            assertThat(result).isEqualTo(ConsumptionPossibility.ENTITLEMENT_INVALID)
        }

        @Test
        fun `checkConsumptionPossibility should return ENTITLEMENT_EXPIRED when entitlement is expired`() {
            entitlementRepository.save(
                entitlements.first().apply {
                    status = EntitlementStatus.EXPIRED
                }
            )

            val result = subject.checkConsumptionPossibility(manager, firstPerson.id, campaigns.first().id)
            assertThat(result).isEqualTo(ConsumptionPossibility.ENTITLEMENT_EXPIRED)
        }

        @Test
        fun `checkConsumptionPossibility should return CONSUMPTION_ALREADY_DONE when consumption happened in the past in same period`() {
            val consumedAt = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
            mockConsumptions(entitlements, consumedAt)

            val result = subject.checkConsumptionPossibility(manager, firstPerson.id, campaigns.first().id)
            assertThat(result).isEqualTo(ConsumptionPossibility.CONSUMPTION_ALREADY_DONE)
        }

        @Test
        fun `checkConsumptionPossibility should return CONSUMPTION_POSSIBLE when consumption is possible`() {
            val consumedAt = ZonedDateTime.of(2023, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
            mockConsumptions(entitlements, consumedAt)

            val result = subject.checkConsumptionPossibility(manager, firstPerson.id, campaigns.first().id)
            assertThat(result).isEqualTo(ConsumptionPossibility.CONSUMPTION_POSSIBLE)
        }
    }

    private fun mockConsumptions(
        entitlements: List<Entitlement>,
        consumedAt: ZonedDateTime
    ): MutableList<Consumption> {
        val consumptions = entitlements.map {
            Mocks.mockConsumption(
                personId = it.personId,
                entitlementCauseId = it.entitlementCauseId,
                campaignId = it.campaignId,
                consumedAt = consumedAt
            )
        }
        return consumptionRepository.saveAll(consumptions)
    }

    private fun mockEntitlements(): List<Entitlement> {
        val cause1 = persons.map {
            Mocks.mockEntitlement(it.id, entitlementCauseId = causes[0].id, campaignId = campaigns[0].id)
        }
        val cause2 = persons.map {
            Mocks.mockEntitlement(it.id, entitlementCauseId = causes[1].id, campaignId = campaigns[1].id)
        }

        val allCauses = cause1 + cause2
        return allCauses.map {
            entitlementRepository.save(it)
        }
    }

    @Nested
    inner class FindConsumptions {

        @BeforeEach
        fun beforeEach() {
            personRepository.saveAll(persons)
            campaignRepository.saveAll(campaigns)
            causeRepository.saveAll(causes)

            entitlements = mockEntitlements()

            items1 = mockConsumptions(entitlements, day1)
            items2 = mockConsumptions(entitlements, day2)
            items3 = mockConsumptions(entitlements, day3)
        }

        @Test
        fun `findConsumptions should fail for unknown entitlementCauseId`() {
            assertThrows<EntitlementsError.NoEntitlementCauseFound> {
                subject.findConsumptions(manager, causeId = newId())
            }
        }

        @Test
        fun `findConsumptions should fail for unknown campaignId`() {
            assertThrows<EntitlementsError.NoCampaignFound> {
                subject.findConsumptions(manager, campaignId = newId())
            }
        }

        @Test
        fun `findConsumptions should fail for unknown personId`() {
            assertThrows<PersonsError.NotFoundException> {
                subject.findConsumptions(manager, personId = newId())
            }
        }

        @Test
        fun `findConsumptions should return all for a person`() {
            val result = subject.findConsumptions(reader, personId = firstPerson.id)
            result.forEach {
                assertThat(it.personId).isEqualTo(firstPerson.id)
            }
        }

        @Test
        fun `findConsumptions should find all consumptions of all dates`() {
            val result = subject.findConsumptions(manager, from = day1, to = day3)
            assertThat(result).hasSize(items1.size + items2.size + items3.size)
        }

        @Test
        fun `findConsumptions should find consumptions of single day`() {
            val result = subject.findConsumptions(manager, from = day2, to = day2)
            result.forEach {
                assertThat(it.consumedAt).isAfterOrEqualTo(day1)
                assertThat(it.consumedAt).isBeforeOrEqualTo(day3)
                assertThat(it.consumedAt).isBetween(day2, day2)
            }
            assertThat(result).hasSize(items1.size)
        }

        @Test
        fun `findConsumptions should find consumptions of range 1`() {
            val result = subject.findConsumptions(manager, from = day1, to = day2)
            result.forEach {
                assertThat(it.consumedAt).isBeforeOrEqualTo(day3)
                assertThat(it.consumedAt).isBetween(day1, day2)
            }
            assertThat(result).hasSize(items2.size + items3.size)
        }

        @Test
        fun `findConsumptions should find consumptions of range 2`() {
            val result = subject.findConsumptions(manager, from = day2, to = day3)
            result.forEach {
                assertThat(it.consumedAt).isAfterOrEqualTo(day1)
                assertThat(it.consumedAt).isBetween(day2, day3)
            }
            assertThat(result).hasSize(items2.size + items3.size)
        }

        @Test
        fun `findConsumptions should find not find for wrong dates`() {
            val result = subject.findConsumptions(manager, from = ZonedDateTime.now(), to = ZonedDateTime.now())
            assertThat(result).hasSize(0)
        }
    }

    @Nested
    inner class GetBeginningOfCurrentPeriod {

        val dateTime = LocalDate.of(2024, 2, 15)

        @Test
        fun `getBeginningOfCurrentPeriod should return 2023 for ONCE`() {
            val result = subject.getBeginningOfCurrentPeriod(Period.ONCE, dateTime)
            assertThat(result).isEqualTo(LocalDate.of(2023, 1, 1))
        }

        @Test
        fun `getBeginningOfCurrentPeriod should return 2024-01-01 for YEARLY`() {
            val result = subject.getBeginningOfCurrentPeriod(Period.YEARLY, dateTime)
            assertThat(result).isEqualTo(LocalDate.of(2024, 1, 1))
        }

        @Test
        fun `getBeginningOfCurrentPeriod should return 2024-02-01 for MONTHLY`() {
            val result = subject.getBeginningOfCurrentPeriod(Period.MONTHLY, dateTime)
            assertThat(result).isEqualTo(LocalDate.of(2024, 2, 1))
        }

        @Test
        fun `getBeginningOfCurrentPeriod should return 2024-02-12 for WEEKLY`() {
            val result = subject.getBeginningOfCurrentPeriod(Period.WEEKLY, dateTime)
            assertThat(result).isEqualTo(LocalDate.of(2024, 2, 12))
        }
    }

    @Nested
    inner class PerformConsumption {

        @BeforeEach
        fun beforeEach() {
            personRepository.saveAll(persons)
            campaignRepository.saveAll(campaigns)
            causeRepository.saveAll(causes)

            entitlements = persons.map {
                entitlementRepository.save(Mocks.mockEntitlement(it.id, causes[0].id, campaigns[0].id))
            }
        }

        @Test
        fun `performConsumption should throw NotFoundException for missing person `() {
            assertThrows<PersonsError.NotFoundException> {
                subject.performConsumption(manager, newId(), causes.first().id)
            }
        }

        @Test
        fun `performConsumption should throw NoEntitlementCauseFound for missing entitlement cause `() {
            assertThrows<EntitlementsError.NoEntitlementCauseFound> {
                subject.performConsumption(manager, firstPerson.id, newId())
            }
        }

        @Test
        fun `performConsumption should throw NoEntitlementFound for missing Entitlement`() {
            entitlementRepository.deleteAll()
            assertThrows<EntitlementsError.NoEntitlementFound> {
                subject.performConsumption(manager, firstPerson.id, causes.first().id)
            }
        }

        @Test
        fun `performConsumption should throw NotPossibleError with ENTITLEMENT_INVALID when entitlement is invalid`() {
            entitlementRepository.save(
                entitlements.first().apply {
                    status = EntitlementStatus.INVALID
                }
            )
            val result = assertThrows<ConsumptionsError.NotPossibleError> {
                subject.performConsumption(manager, firstPerson.id, causes.first().id)
            }
            assertThat(result.value).isEqualTo(ConsumptionPossibility.ENTITLEMENT_INVALID)
        }

        @Test
        fun `performConsumption should throw NotPossibleError with ENTITLEMENT_EXPIRED when entitlement is expired`() {
            entitlementRepository.save(
                entitlements.first().apply {
                    status = EntitlementStatus.EXPIRED
                }
            )

            val result = assertThrows<ConsumptionsError.NotPossibleError> {
                subject.performConsumption(manager, firstPerson.id, causes.first().id)
            }
            assertThat(result.value).isEqualTo(ConsumptionPossibility.ENTITLEMENT_EXPIRED)
        }

        @Test
        fun `performConsumption should throw AlreadyDoneError CONSUMPTION_ALREADY_DONE when consumption happened in the past in same period`() {
            val consumedAt = ZonedDateTime.of(2024, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
            mockConsumptions(entitlements, consumedAt)

            val result = assertThrows<ConsumptionsError.AlreadyDoneError> {
                subject.performConsumption(manager, firstPerson.id, causes.first().id)
            }
            assertThat(result.value).isEqualTo(ConsumptionPossibility.CONSUMPTION_ALREADY_DONE)
        }

        @Test
        fun `performConsumption should return consumption when consumption was made`() {
            val consumedAt = ZonedDateTime.of(2023, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
            mockConsumptions(entitlements, consumedAt)

            val result = subject.performConsumption(manager, firstPerson.id, causes.first().id)
            assertThat(result).isNotNull
        }

        @Test
        fun `performConsumption should return consumption with same values like Entitlement`() {
            val consumedAt = ZonedDateTime.of(2023, 1, 1, 12, 0, 0, 0, ZoneId.systemDefault())
            mockConsumptions(entitlements, consumedAt)

            val result = subject.performConsumption(manager, firstPerson.id, causes.first().id)
            assertThat(result).isNotNull

            val consumption = consumptionRepository.findByIdOrNull(result.id)!!
            assertThat(consumption.personId).isEqualTo(firstPerson.id)
            assertThat(consumption.entitlementCauseId).isEqualTo(causes.first().id)
            assertThat(consumption.campaignId).isEqualTo(causes.first().campaignId)
            assertDateTime(consumption.consumedAt).isApproximatelyNow()
            assertThat(consumption.entitlementData).isEqualTo(entitlements.first().values)
        }
    }
}
