package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.testcommons.AbstractMongoDbServiceTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.data.repository.findByIdOrNull
import java.time.LocalDate
import java.time.ZonedDateTime

class PersonsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var personRepository: PersonRepository

    lateinit var subject: PersonsServiceImpl

    @BeforeEach
    fun beforeEach() {
        subject = PersonsServiceImpl(personRepository)
        personRepository.deleteAll()
        personRepository.saveAll(persons)
    }

    @Nested
    inner class createPerson {
        val request = CreatePerson(
            firstName = "John",
            lastName = "Doe",
            dateOfBirth = LocalDate.of(1990, 1, 1).toString(),
            address = Address(
                addressId = "123",
                streetNameNumber = "Main Street 1",
                addressSuffix = "a",
                postalCode = "1020"
            ),
            email = "",
            mobileNumber = "1234567890",
            gender = Gender.DIVERSE
        )

        @Test
        fun `createPerson should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                subject.createPerson(reader, request, strictMode = false)
            }
        }

        @Test
        fun `createPerson should be allowed for MANAGER`() {
            val result = subject.createPerson(manager, request, strictMode = false)
            assertThat(result).isNotNull
        }

        @Test
        fun `createPerson should save person in storage`() {
            val result = subject.createPerson(manager, request, strictMode = false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person).isEqualTo(result)

            val almostNow = ZonedDateTime.now().minusSeconds(1)
            assertThat(person!!.createdAt).isAfter(almostNow)
            assertThat(person.updatedAt).isAfter(almostNow)
        }

        @Test
        fun `createPerson should save person without duplicates without similarIds`() {
            val result = subject.createPerson(manager, request, strictMode = false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isEmpty()
        }

        @Test
        fun `createPerson should save person with duplicates with similarIds`() {
            val result1 = subject.createPerson(manager, request, strictMode = false)
            val result2 = subject.createPerson(manager, request, strictMode = false)

            val person = personRepository.findByIdOrNull(result2.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result1.id)
        }

        @Test
        fun `createPerson should also set similarIds on prior existing persons`() {
            val result1 = subject.createPerson(manager, request, strictMode = false)
            val result2 = subject.createPerson(manager, request, strictMode = false)

            val person = personRepository.findByIdOrNull(result1.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result2.id)
        }

        @Test
        fun `createPerson should return error when strictMode is used and duplicates are found`() {
            subject.createPerson(manager, request, strictMode = false)
            assertThrows<PersonsError.StrictModeDuplicatesCreation> {
                subject.createPerson(manager, request, strictMode = true)
            }
        }

        @Test
        fun `createPerson should not return error when strictMode is not used and duplicates are found`() {
            subject.createPerson(manager, request, strictMode = false)
            subject.createPerson(manager, request, strictMode = false)
        }
    }

    @Nested
    inner class listPersons {
        @Test
        fun `listPersons should be allowed for READER`() {
            val persons = subject.listPersons(reader)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getPerson {
        @Test
        fun `getPerson should be allowed for READER`() {
            val persons = subject.getPerson(reader, firstPerson.id)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getPersonSimilars {
        @Test
        fun `getPersonSimilars should be allowed for READER`() {
            val persons = subject.getPersonSimilars(reader, firstPerson.id)
            assertThat(persons).isNotNull

            val person = subject.getPerson(reader, firstPerson.id)
            val map = persons.map { it.id }
            assertThat(map).containsExactlyInAnyOrderElementsOf(person!!.similarPersonIds)
        }
    }

    @Nested
    inner class findSimilarPersons {

        @Test
        fun `findSimilarPersons should be allowed for READER`() {
            subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, firstPerson.dateOfBirth)
        }

        @Test
        fun `findSimilarPersons should find exact match with dateOfBirth`() {
            val persons =
                subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, firstPerson.dateOfBirth)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.first()).isEqualTo(firstPerson)
        }

        @Test
        fun `findSimilarPersons should ignore dateOfBirth when not given`() {
            val persons = subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, null)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(2)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.firstName).isEqualTo(firstPerson.firstName)
                assertThat(it.lastName).isEqualTo(firstPerson.lastName)
            }
        }
    }

    @Nested
    inner class findWithSimilarAddress {

        @Test
        fun `findWithSimilarAddress should be allowed for READER`() {
            subject.findWithSimilarAddress(
                reader,
                null,
                null,
                null
            )
        }

        @Test
        fun `findWithSimilarAddress should find by streetNameNumber`() {
            val persons =
                subject.findWithSimilarAddress(
                    reader,
                    null,
                    firstPerson.address?.streetNameNumber,
                    null,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(5)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.address?.streetNameNumber).isEqualTo(firstPerson.address?.streetNameNumber)
            }
        }

        @Test
        fun `findWithSimilarAddress should find by streetNameNumber and addressSuffix`() {
            val persons =
                subject.findWithSimilarAddress(
                    reader,
                    null,
                    firstPerson.address?.streetNameNumber,
                    firstPerson.address?.addressSuffix,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(2)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.address?.streetNameNumber).isEqualTo(firstPerson.address?.streetNameNumber)
                assertThat(it.address?.addressSuffix).isEqualTo(firstPerson.address?.addressSuffix)
            }
        }

        @Test
        fun `findWithSimilarAddress should find by addressId`() {
            val persons =
                subject.findWithSimilarAddress(
                    reader,
                    firstPerson.address?.addressId,
                    null,
                    null,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(2)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.address?.addressId).isEqualTo(firstPerson.address?.addressId)
            }
        }

        @Test
        fun `findWithSimilarAddress should find by addressId and addressSuffix`() {
            val persons =
                subject.findWithSimilarAddress(
                    reader,
                    firstPerson.address?.addressId,
                    null,
                    firstPerson.address?.addressSuffix,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(2)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.address?.addressId).isEqualTo(firstPerson.address?.addressId)
                assertThat(it.address?.addressSuffix).isEqualTo(firstPerson.address?.addressSuffix)
            }
        }
    }
}
