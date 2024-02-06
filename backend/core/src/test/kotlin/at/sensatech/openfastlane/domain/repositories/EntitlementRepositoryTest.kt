package at.sensatech.openfastlane.domain.repositories

import at.sensatech.openfastlane.common.newId
import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import org.springframework.beans.factory.annotation.Autowired
internal class EntitlementRepositoryTest : AbstractRepositoryTest<Entitlement, String, EntitlementRepository>() {

    @Autowired
    override lateinit var repository: EntitlementRepository

    override fun createDefaultEntityPair(id: String): Pair<String, Entitlement> {
        val entitlement = Entitlement(
            id,
            newId(),
            arrayListOf()
        )
        return Pair(id, entitlement)
    }

    override fun changeEntity(entity: Entitlement) = entity.apply {
        values.add(
            EntitlementValue(
                "changed",
                EntitlementCriteriaType.TEXT,
                "changed"
            )
        )
    }
}
