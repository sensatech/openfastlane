package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Person
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface PersonRepository : MongoRepository<
        Person, String>