package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Person
import at.sensatech.openfastlane.domain.repositories.PersonRepository
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Test
import org.springframework.data.repository.findByIdOrNull

class PersonsServiceImplTest : AbstractMockedServiceTest() {

    private val personRepository: PersonRepository = mockk {
        every { findAll() } returns persons
        every { findByIdOrNull(any()) } returns null
        every { findByIdOrNull(firstPerson.id) } returns firstPerson
        every { save(any()) } answers { firstArg() as Person }
    }

    private val subject = PersonsServiceImpl(personRepository)


    @Nested
    inner class listPersons {
        @Test
        fun `listPersons should be allowed for READER`() {
            val persons = subject.listPersons(reader)
            assertThat(persons).isNotNull

            verify { personRepository.findAll() }

        }
    }

    @Nested
    inner class findById {
        @Test
        fun `findById should be allowed for READER`() {
            val persons = subject.getPerson(reader, firstPerson.id)
            assertThat(persons).isNotNull

            verify { personRepository.findByIdOrNull(firstPerson.id) }
        }
    }
}
