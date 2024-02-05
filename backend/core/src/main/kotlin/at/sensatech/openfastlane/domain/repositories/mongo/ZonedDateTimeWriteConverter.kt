package at.sensatech.openfastlane.domain.repositories.mongo

import org.bson.Document
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.WritingConverter
import org.springframework.stereotype.Component
import java.time.ZonedDateTime
import java.util.Date

@Component
@WritingConverter
class ZonedDateTimeWriteConverter : Converter<ZonedDateTime, Document?> {
    override fun convert(zonedDateTime: ZonedDateTime): Document {
        val document = Document()
        document[DATE_TIME] = Date.from(zonedDateTime.toInstant())
        document[ZONE] = zonedDateTime.zone.id
        document["offset"] = zonedDateTime.offset.toString()
        return document
    }

    companion object {
        const val DATE_TIME: String = "dateTime"
        const val ZONE: String = "zone"
    }
}
