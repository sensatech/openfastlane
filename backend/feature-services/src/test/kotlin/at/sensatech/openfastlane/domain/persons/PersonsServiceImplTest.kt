package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.domain.services.UserError
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

    val createRequest = CreatePerson(
        firstName = "CreatePerson",
        lastName = "Test",
        dateOfBirth = LocalDate.of(1990, 1, 1).toString(),
        address = Address(
            addressId = "123",
            streetNameNumber = "Hausgasse 2",
            addressSuffix = "1",
            postalCode = "1010"
        ),
        email = "",
        mobileNumber = "1234567890",
        gender = Gender.DIVERSE
    )

    @BeforeEach
    fun beforeEach() {
        subject = PersonsServiceImpl(personRepository)
        personRepository.deleteAll()
        personRepository.saveAll(persons)
    }

    @Nested
    inner class createPerson {

        @Test
        fun `createPerson should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                subject.createPerson(reader, createRequest, strictMode = false)
            }
        }

        @Test
        fun `createPerson should be allowed for MANAGER`() {
            val result = subject.createPerson(manager, createRequest, strictMode = false)
            assertThat(result).isNotNull
        }

        @Test
        fun `createPerson should save person in storage`() {
            val result = subject.createPerson(manager, createRequest, strictMode = false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person).isEqualTo(result)

            val almostNow = ZonedDateTime.now().minusSeconds(1)
            assertThat(person!!.createdAt).isAfter(almostNow)
            assertThat(person.updatedAt).isAfter(almostNow)
        }

        @Test
        fun `createPerson should save person without duplicates without similarIds`() {
            val result = subject.createPerson(manager, createRequest, strictMode = false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isEmpty()
        }

        @Test
        fun `createPerson should save person with duplicates with similarIds`() {
            val result1 = subject.createPerson(manager, createRequest, strictMode = false)
            val result2 = subject.createPerson(manager, createRequest, strictMode = false)

            val person = personRepository.findByIdOrNull(result2.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result1.id)
        }

        @Test
        fun `createPerson should also set similarIds on prior existing persons`() {
            val result1 = subject.createPerson(manager, createRequest, strictMode = false)
            val result2 = subject.createPerson(manager, createRequest, strictMode = false)

            val person = personRepository.findByIdOrNull(result1.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result2.id)
        }

        @Test
        fun `createPerson should append CREATED to the audit log`() {
            val result = subject.createPerson(manager, createRequest, strictMode = false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.audit).isNotEmpty
            assertThat(person.audit).hasSize(1)

            val auditItem = person.audit[0]
            assertThat(auditItem.user).isEqualTo(manager.username)
            assertThat(auditItem.action).isEqualTo("CREATED")
        }

        @Test
        fun `createPerson should return error when strictMode is used and duplicates are found`() {
            subject.createPerson(manager, createRequest, strictMode = false)
            assertThrows<PersonsError.StrictModeDuplicatesCreation> {
                subject.createPerson(manager, createRequest, strictMode = true)
            }
        }

        @Test
        fun `createPerson should not return error when strictMode is not used and duplicates are found`() {
            subject.createPerson(manager, createRequest, strictMode = false)
            subject.createPerson(manager, createRequest, strictMode = false)
        }
    }

    @Nested
    inner class updatePerson {
        val updateRequest = UpdatePerson(
            firstName = "UpdatePerson",
            lastName = "Test",
            dateOfBirth = LocalDate.of(1990, 1, 1).toString(),
            address = Address(
                addressId = "123",
                streetNameNumber = "Hausgasse 3",
                addressSuffix = "1",
                postalCode = "1010"
            ),
            email = "",
            mobileNumber = "1234567890",
            gender = Gender.DIVERSE,
            comment = "Some comment"
        )

        @Test
        fun `updatePerson should not be allowed for READER`() {
            assertThrows<UserError.InsufficientRights> {
                subject.updatePerson(reader, firstPerson.id, updateRequest)
            }
        }

        @Test
        fun `updatePerson should be allowed for MANAGER`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest)
            assertThat(result).isNotNull
        }

        @Test
        fun `updatePerson should not save non-existing person`() {
            assertThrows<PersonsError.NotFoundException> {
                subject.updatePerson(manager, newId(), updateRequest)
            }
        }

        @Test
        fun `updatePerson should save person in storage`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.id).isEqualTo(firstPerson.id)
        }

        @Test
        fun `updatePerson should save person without duplicates without similarIds`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isEmpty()
        }

        @Test
        fun `updatePerson should save person with duplicates with similarIds`() {
            val result1 = subject.updatePerson(manager, firstPerson.id, updateRequest)
            val result2 = subject.updatePerson(manager, firstPerson.id, updateRequest)

            val person = personRepository.findByIdOrNull(result2.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result1.id)
        }

        @Test
        fun `updatePerson should only PATCH the person for the chosen fields`() {
            val minimalRequest = UpdatePerson(lastName = "Test2")
            val result = subject.updatePerson(manager, firstPerson.id, minimalRequest)

            val updatedPerson = personRepository.findByIdOrNull(result.id)
            assertThat(updatedPerson).isNotNull
            assertThat(updatedPerson!!).isEqualTo(result)

            assertThat(result.id).isEqualTo(firstPerson.id)
            assertThat(result.firstName).isEqualTo(firstPerson.firstName)
            assertThat(result.dateOfBirth).isEqualTo(firstPerson.dateOfBirth)
            assertThat(result.address).isEqualTo(firstPerson.address)
            assertThat(result.email).isEqualTo(firstPerson.email)
            assertThat(result.mobileNumber).isEqualTo(firstPerson.mobileNumber)
            assertThat(result.comment).isEqualTo(firstPerson.comment)
            assertThat(result.createdAt).isEqualTo(firstPerson.createdAt.withNano(result.createdAt.nano))

            // not equals
            assertThat(result.updatedAt).isNotEqualTo(firstPerson.updatedAt)
            assertThat(result.lastName).isNotEqualTo(firstPerson.lastName)
        }

        @Test
        fun `updatePerson should update updatedAt but not updatedAt`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest)

            Thread.sleep(10)
            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person).isEqualTo(result)

            val almostNow = ZonedDateTime.now().minusSeconds(1)
            assertThat(person!!.updatedAt).isAfter(almostNow)
            assertThat(person.updatedAt).isAfter(person.createdAt)
        }

        @Test
        fun `updatePerson should append UPDATE to the audit log`() {
            subject.updatePerson(manager, firstPerson.id, updateRequest)

            val person = personRepository.findByIdOrNull(firstPerson.id)
            assertThat(person).isNotNull
            assertThat(person!!.audit).isNotEmpty
            assertThat(person.audit).hasSize(1)

            val auditItem = person.audit[0]
            assertThat(auditItem.user).isEqualTo(manager.username)
            assertThat(auditItem.action).isEqualTo("UPDATED")
        }

        @Test
        fun `updatePerson should append every UPDATE to the audit log`() {
            val createdPerson = subject.createPerson(manager, createRequest, strictMode = false)
            subject.updatePerson(manager, createdPerson.id, updateRequest)
            subject.updatePerson(manager, createdPerson.id, updateRequest)

            val updatedPerson = personRepository.findByIdOrNull(createdPerson.id)
            assertThat(updatedPerson).isNotNull
            assertThat(updatedPerson!!.audit).isNotEmpty

            val audit = updatedPerson.audit
            assertThat(audit[0].user).isEqualTo(manager.username)
            assertThat(audit[1].user).isEqualTo(manager.username)
        }

        @Test
        fun `updatePerson should update similarIds`() {
            subject.createPerson(manager, createRequest, strictMode = false)
            subject.createPerson(manager, createRequest, strictMode = false)
            val person3 = subject.createPerson(manager, createRequest, strictMode = false)

            assertThat(person3.similarPersonIds).doesNotContain(firstPerson.id)
            assertThat(person3.similarPersonIds).doesNotContain(duplicatePerson.id)

            val updatedWithAddress = subject.updatePerson(
                manager,
                person3.id,
                updateRequest.copy(
                    address = firstPerson.address
                )
            )

            assertThat(updatedWithAddress).isNotNull
            assertThat(updatedWithAddress.similarPersonIds).isNotEmpty
            assertThat(updatedWithAddress.similarPersonIds).containsExactly(firstPerson.id, duplicatePerson.id)
        }

        @Test
        fun `updatePerson should also set similarIds on prior existing persons`() {
            subject.createPerson(manager, createRequest, strictMode = false)
            subject.createPerson(manager, createRequest, strictMode = false)
            val person3 = subject.createPerson(manager, createRequest, strictMode = false)

            personRepository.findByIdOrNull(firstPerson.id).let {
                assertThat(it!!.similarPersonIds).doesNotContain(person3.id)
            }

            personRepository.findByIdOrNull(duplicatePerson.id).let {
                assertThat(it!!.similarPersonIds).doesNotContain(person3.id)
            }

            val updatedWithAddress = subject.updatePerson(
                manager,
                person3.id,
                updateRequest.copy(address = firstPerson.address)
            )

            assertThat(updatedWithAddress).isNotNull
            assertThat(updatedWithAddress.similarPersonIds).isNotEmpty

            personRepository.findByIdOrNull(firstPerson.id).let {
                assertThat(it!!.similarPersonIds).contains(person3.id)
            }

            personRepository.findByIdOrNull(duplicatePerson.id).let {
                assertThat(it!!.similarPersonIds).contains(person3.id)
            }
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
