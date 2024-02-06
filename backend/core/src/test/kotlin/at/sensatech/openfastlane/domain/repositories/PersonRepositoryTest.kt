package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Address
import at.sensatech.openfastlane.domain.models.Gender
import at.sensatech.openfastlane.domain.models.Person
import org.springframework.beans.factory.annotation.Autowired
import java.time.LocalDate
import java.time.ZonedDateTime

internal class PersonRepositoryTest : AbstractRepositoryTest<Person, String, PersonRepository>() {

    @Autowired
    override lateinit var repository: PersonRepository
    override fun createDefaultEntityPair(id: String): Pair<String, Person> {
        val person = Person(
            id,
            "owner",
            "lastname",
            LocalDate.now(),
            Gender.DIVERSE,
            Address("street", "city", "zip", "country"),
            null,
            null,
            emptySet(),
            "comment",
            ZonedDateTime.now(),
            ZonedDateTime.now(),
        )
        return Pair(id, person)
    }

    override fun changeEntity(entity: Person) = entity.apply { firstName = "changed" }
}
