package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.Consumption
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementValue
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface EntitlementCriteriaRepository : MongoRepository<EntitlementCriteria, String>

@Repository
interface EntitlementValueRepository : MongoRepository<EntitlementValue, String>

@Repository
interface ConsumptionRepository : MongoRepository<Consumption, String>
