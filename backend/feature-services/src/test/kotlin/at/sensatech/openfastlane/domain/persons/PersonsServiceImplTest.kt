package at.sensatech.openfastlane.domain.persons

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.assertDateTime
import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
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
import java.time.LocalDate
import java.time.ZonedDateTime

class PersonsServiceImplTest : AbstractMongoDbServiceTest() {

    @Autowired
    lateinit var personRepository: PersonRepository

    @Autowired
    lateinit var entitlementRepository: EntitlementRepository

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
        subject = PersonsServiceImpl(personRepository, entitlementRepository)
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
                subject.updatePerson(reader, firstPerson.id, updateRequest, false)
            }
        }

        @Test
        fun `updatePerson should be allowed for MANAGER`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest, false)
            assertThat(result).isNotNull
        }

        @Test
        fun `updatePerson should not save non-existing person`() {
            assertThrows<PersonsError.NotFoundException> {
                subject.updatePerson(manager, newId(), updateRequest, false)
            }
        }

        @Test
        fun `updatePerson should save person in storage`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest, false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.id).isEqualTo(firstPerson.id)
        }

        @Test
        fun `updatePerson should save person without duplicates without similarIds`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest, false)

            val person = personRepository.findByIdOrNull(result.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isEmpty()
        }

        @Test
        fun `updatePerson should save person with duplicates with similarIds`() {
            val result1 = subject.updatePerson(manager, firstPerson.id, updateRequest, false)
            val result2 = subject.updatePerson(manager, firstPerson.id, updateRequest, false)

            val person = personRepository.findByIdOrNull(result2.id)
            assertThat(person).isNotNull
            assertThat(person!!.similarPersonIds).isNotEmpty
            assertThat(person.similarPersonIds).containsExactly(result1.id)
        }

        @Test
        fun `updatePerson should only PATCH the person for the chosen fields`() {
            val minimalRequest = UpdatePerson(lastName = "Test2")
            val result = subject.updatePerson(manager, firstPerson.id, minimalRequest, false)

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
            assertDateTime(result.createdAt).isApproximately(firstPerson.createdAt)

            // not equals
            assertThat(result.updatedAt).isNotEqualTo(firstPerson.updatedAt)
            assertThat(result.lastName).isNotEqualTo(firstPerson.lastName)
        }

        @Test
        fun `updatePerson should update updatedAt but not updatedAt`() {
            val result = subject.updatePerson(manager, firstPerson.id, updateRequest, false)

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
            subject.updatePerson(manager, firstPerson.id, updateRequest, false)

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
            subject.updatePerson(manager, createdPerson.id, updateRequest, false)
            subject.updatePerson(manager, createdPerson.id, updateRequest, false)

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
                ),
                false
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
                updateRequest.copy(address = firstPerson.address),
                false
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
            val persons = subject.listPersons(reader, false)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class getPerson {
        @Test
        fun `getPerson should be allowed for READER`() {
            val person = subject.getPerson(reader, firstPerson.id, false)
            assertThat(person).isNotNull
        }

        @Test
        fun `getPerson should return nested entitlements`() {
            entitlementRepository.save(Mocks.mockEntitlement(firstPerson.id))
            val person = subject.getPerson(reader, firstPerson.id, true)
            assertThat(person).isNotNull
            assertThat(person?.entitlements).isNotNull
            assertThat(person?.entitlements).isNotEmpty
        }
    }

    @Nested
    inner class getPersonSimilars {
        @Test
        fun `getPersonSimilars should be allowed for READER`() {
            val persons = subject.getPersonSimilars(reader, firstPerson.id, false)
            assertThat(persons).isNotNull

            val person = subject.getPerson(reader, firstPerson.id, false)
            val map = persons.map { it.id }
            assertThat(map).containsExactlyInAnyOrderElementsOf(person!!.similarPersonIds)
        }
    }

    @Nested
    inner class findSimilarPersons {

        @Test
        fun `findSimilarPersons should be allowed for READER`() {
            subject.findSimilarPersons(
                reader,
                firstPerson.firstName,
                firstPerson.lastName,
                firstPerson.dateOfBirth,
                false
            )
        }

        @Test
        fun `findSimilarPersons should find exact match with dateOfBirth`() {
            val persons =
                subject.findSimilarPersons(
                    reader,
                    firstPerson.firstName,
                    firstPerson.lastName,
                    firstPerson.dateOfBirth,
                    false
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.first()).isEqualTo(firstPerson)
        }

        @Test
        fun `findSimilarPersons should find exact match reversed`() {
            val persons =
                subject.findSimilarPersons(
                    reader,
                    firstPerson.lastName,
                    firstPerson.firstName,
                    firstPerson.dateOfBirth,
                    false
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.first()).isEqualTo(firstPerson)
        }

        @Test
        fun `findSimilarPersons should ignore dateOfBirth when not given`() {
            val persons = subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, null, false)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(3)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.firstName).isEqualTo(firstPerson.firstName)
                assertThat(it.lastName).isEqualTo(firstPerson.lastName)
            }
        }

        @Test
        fun `findSimilarPersons should ignore dateOfBirth reversed`() {
            val persons = subject.findSimilarPersons(reader, firstPerson.lastName, firstPerson.firstName, null, false)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(3)
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
                null,
                false
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
                    false
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(6)
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
                    false
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
                    false,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(3)
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
                    false,
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

    @Nested
    inner class find {

        @Test
        fun `find should be allowed for READER`() {
            subject.find(
                reader,
                firstPerson.firstName,
                firstPerson.lastName,
                firstPerson.dateOfBirth,
            )
        }

        @Test
        fun `find should find exact match with dateOfBirth`() {
            val persons =
                subject.find(
                    reader,
                    firstPerson.firstName,
                    firstPerson.lastName,
                    firstPerson.dateOfBirth,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.first()).isEqualTo(firstPerson)
        }

        @Test
        fun `find should ignore dateOfBirth when not given`() {
            val persons = subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, null, false)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(3)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.firstName).isEqualTo(firstPerson.firstName)
                assertThat(it.lastName).isEqualTo(firstPerson.lastName)
            }
        }

        @Test
        fun `find should combine name and address search`() {
            val persons =
                subject.find(
                    reader,
                    firstPerson.firstName,
                    firstPerson.lastName,
                    firstPerson.dateOfBirth,
                    addressId = firstPerson.address?.addressId,
                    streetNameNumber = firstPerson.address?.streetNameNumber,
                    addressSuffix = firstPerson.address?.addressSuffix,
                )
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.contains(firstPerson)).isTrue()
            persons.forEach {
                assertThat(it.address?.addressId).isEqualTo(firstPerson.address?.addressId)
                assertThat(it.address?.addressSuffix).isEqualTo(firstPerson.address?.addressSuffix)
            }
        }
    }
}
