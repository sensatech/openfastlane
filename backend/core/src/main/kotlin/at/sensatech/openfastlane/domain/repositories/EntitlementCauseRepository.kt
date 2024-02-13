package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.EntitlementCause
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface EntitlementCauseRepository : MongoRepository<EntitlementCause, String>
