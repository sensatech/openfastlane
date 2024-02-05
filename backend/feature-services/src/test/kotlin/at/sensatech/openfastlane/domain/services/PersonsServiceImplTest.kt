package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.repositories.PersonRepository
import at.sensatech.openfastlane.testcommons.AbstractMongoDbServiceTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired

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
        fun `findById should be allowed for READER`() {
            val persons = subject.getPerson(reader, firstPerson.id)
            assertThat(persons).isNotNull
        }
    }

    @Nested
    inner class findSimilarPersons {

        @Test
        fun `findSimilarPersons should be allowed for READER`() {
            subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, firstPerson.birthDate)
        }

        @Test
        fun `findSimilarPersons should find exact match with birthday`() {
            val persons =
                subject.findSimilarPersons(reader, firstPerson.firstName, firstPerson.lastName, firstPerson.birthDate)
            assertThat(persons).isNotNull
            assertThat(persons).hasSize(1)
            assertThat(persons.first()).isEqualTo(firstPerson)
        }

        @Test
        fun `findSimilarPersons should ignore birthdate when not given`() {
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
