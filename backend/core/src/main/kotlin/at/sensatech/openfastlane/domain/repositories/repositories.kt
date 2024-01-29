package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.domain.models.*
import org.springframework.data.mongodb.repository.MongoRepository
import org.springframework.stereotype.Repository

@Repository
interface CampaignRepository : MongoRepository<Campaign, String>

@Repository
interface EntitlementCauseRepository : MongoRepository<EntitlementCause, String>

@Repository
interface EntitlementCriteriaRepository : MongoRepository<EntitlementCriteria, String>

@Repository
interface EntitlementValueRepository : MongoRepository<EntitlementValue, String>

@Repository
interface PersonRepository : MongoRepository<Person, String>

@Repository
interface EntitlementRepository : MongoRepository<Entitlement, String>

@Repository
interface ConsumptionRepository : MongoRepository<Consumption, String>
