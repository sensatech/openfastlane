package at.sensatech.openfastlane.domain.repositories.mongo

import com.mongodb.MongoClientSettings
import org.bson.codecs.configuration.CodecRegistries
import org.bson.codecs.configuration.CodecRegistries.fromCodecs
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.autoconfigure.mongo.MongoClientSettingsBuilderCustomizer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.data.mongodb.config.MongoConfigurationSupport
import org.springframework.data.mongodb.core.convert.MongoCustomConversions


@Configuration
class MongoConfiguration : MongoConfigurationSupport() {

    @Value("\${spring.data.mongodb.database}")
    private val database: String? = null

    override fun getDatabaseName(): String {
        return database!!
    }

    @Bean
    fun zonedDateTimeCodecCustomizer() = MongoClientSettingsBuilderCustomizer { clientSettingsBuilder ->
        val fromRegistries = CodecRegistries.fromRegistries(
            MongoClientSettings.getDefaultCodecRegistry(),
            fromCodecs(ZonedDateTimeCodec())
        )
        clientSettingsBuilder.codecRegistry(fromRegistries)
    }

    @Bean
    override fun customConversions(): MongoCustomConversions {
        return MongoCustomConversions(
            listOf(
                ZonedDateTimeWriteConverter(),
                ZonedDateTimeReadConverter()
            )
        )
    }

}