package at.sensatech.openfastlane.domain.services

import at.sensatech.openfastlane.domain.models.Campaign
import at.sensatech.openfastlane.domain.models.EntitlementCause
import at.sensatech.openfastlane.domain.models.EntitlementCriteria
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaOption
import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.Period
import at.sensatech.openfastlane.domain.repositories.CampaignRepository
import at.sensatech.openfastlane.domain.repositories.EntitlementCauseRepository
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import org.slf4j.LoggerFactory
import org.springframework.core.io.Resource
import org.springframework.data.repository.findByIdOrNull
import org.springframework.stereotype.Service

@Service
class StartupConfigurationServiceImpl(
    private val campaignRepository: CampaignRepository,
    private val causeRepository: EntitlementCauseRepository,
    private val objectMapper: ObjectMapper,
) : StartupConfigurationService {

    override fun loadStartupConfiguration(campaignsJsonResource: Resource): Boolean {

        if (!campaignsJsonResource.exists()) {
            log.warn("Campaigns JSON resource does not exist!")
            return false
        }

        val content: String = campaignsJsonResource.inputStream.bufferedReader().use { it.readText() }
        return parseCampaigns(content)
    }

    fun parseCampaigns(content: String): Boolean {

        objectMapper.readTree(content).forEach {
            try {
                parseCampaignNode(it)
            } catch (e: Exception) {
                log.error("Error while parsing campaign: ${e.message}")
                log.error("Make sure, YOUR needed campaigns can be parsed properly on server startup!")
                return false
            }
        }
        return true
    }

    fun parseCampaignNode(it: JsonNode): Campaign? {
        val id = it.get("id").asText()
        val name = it.get("name").asText()
        val period = it.get("period").asText()
        val enabled = it.get("enabled")?.asBoolean(true) ?: true
        if (!enabled) {
            log.warn("Campaign $name is disabled, skipping")
            return null
        }
        val campaign = Campaign(id, name, Period.valueOf(period))
        saveOrUpdateCampaign(campaign)

        val causesListNode = it.get("causes")
        if (causesListNode == null) {
            log.warn("No causes found for campaign $name")
        } else {
            causesListNode.forEach { cause ->
                parseCampaignCauseNode(cause)
            }
        }
        return campaign
    }

    fun parseCampaignCauseNode(cause: JsonNode): EntitlementCause? {
        val causeId = cause.get("id").asText()
        val causeCampaignId = cause.get("campaignId").asText()
        val causeName = cause.get("name").asText()
        val entitlementCriteria = cause.get("criterias")

        val enabled = cause.get("enabled")?.asBoolean(true) ?: true
        if (!enabled) {
            log.warn("EntitlementCause $causeName is disabled, skipping")
            return null
        }

        val parsedCriterias = mutableListOf<EntitlementCriteria>()
        entitlementCriteria.forEach { criterion ->
            try {
                val result = parseCauseCriteriaNode(criterion)
                if (result != null) {
                    parsedCriterias.add(result)
                }
            } catch (e: Exception) {
                log.error("Error while parsing campaign's cause criteria: ${e.message}")
                log.error("Faulty Json during startup: $cause")
                log.error("Make sure, YOUR needed cause criteria can be parsed properly on server startup!")
                return null
            }
        }
        if (parsedCriterias.isEmpty()) {
            log.error("No criterias found for cause $causeName, unusable!")
            return null
        }
        val causeEntity = EntitlementCause(causeId, causeCampaignId, causeName, parsedCriterias)
        saveOrUpdateCause(causeEntity)
        return causeEntity
    }

    fun parseCauseCriteriaNode(jsonNode: JsonNode): EntitlementCriteria? {
        val criterionId = jsonNode.get("id").asText()
        val criterionName = jsonNode.get("name").asText()
        val criterionType = jsonNode.get("type").asText()
        val reportKey = jsonNode.get("reportKey")?.asText()
        val criterionOptions = jsonNode.get("options")
        val options = mutableListOf<EntitlementCriteriaOption>()

        criterionOptions.forEach { option ->
            val key = option.get("key").asText()
            val label = option.get("label").asText()
            val description = option.get("description").asText()
            val order = option.get("order").asInt()
            options.add(EntitlementCriteriaOption(key, label, order, description))
        }

        val type = EntitlementCriteriaType.valueOf(criterionType)
        if (type == EntitlementCriteriaType.OPTIONS && options.isEmpty()) {
            log.error("No options found for criterion $criterionName")
            return null
        }
        return EntitlementCriteria(
            criterionId,
            criterionName,
            type,
            reportKey,
            options
        )
    }

    private fun saveOrUpdateCampaign(campaign: Campaign) {
        val existing = campaignRepository.findById(campaign.id)
        if (existing.isPresent) {
            log.info("Updating existing Campaign ${campaign.name}")
        } else {
            log.info("Creating new Campaign ${campaign.name}")
        }
        campaignRepository.save(campaign)
    }

    private fun saveOrUpdateCause(cause: EntitlementCause) {
        val existing = causeRepository.findById(cause.id)
        if (existing.isPresent) {
            log.info("Updating existing EntitlementCause ${cause.name}")
        } else {
            log.info("Creating new EntitlementCause ${cause.name}")
        }
        val campaign = campaignRepository.findByIdOrNull(cause.campaignId)
        if (campaign == null) {
            log.error("Campaign ${cause.campaignId} not found for EntitlementCause ${cause.name}")
            log.error("Fix that: ${cause.campaignId} not found for EntitlementCause ${cause.name}")
            return
        }

        causeRepository.save(cause)
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
