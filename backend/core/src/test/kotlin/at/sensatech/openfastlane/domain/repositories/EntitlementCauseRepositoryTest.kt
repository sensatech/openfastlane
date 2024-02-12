package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import org.springframework.beans.factory.annotation.Autowired

internal class EntitlementCauseRepositoryTest :
    AbstractRepositoryTest<EntitlementCause, String, EntitlementCauseRepository>() {

    @Autowired
    override lateinit var repository: EntitlementCauseRepository

    override fun createDefaultEntityPair(id: String): Pair<String, EntitlementCause> {
        val entitlement = EntitlementCause(
            id,
            newId(),
            newId(),
            arrayListOf()
        )
        return Pair(id, entitlement)
    }

    override fun changeEntity(entity: EntitlementCause) = entity.apply {
        criterias.add(
            EntitlementCriteria(
                newId(),
                "changed",
                EntitlementCriteriaType.TEXT,
                "changed"
            )
        )
    }
}
