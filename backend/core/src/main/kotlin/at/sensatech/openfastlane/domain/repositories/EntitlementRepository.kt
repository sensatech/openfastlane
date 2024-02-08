package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Entitlement
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface EntitlementRepository : MongoRepository<Entitlement, String> {
    fun findByPersonId(personId: String): List<Entitlement>
}
