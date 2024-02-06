package at.sensatech.openfastlane.domain.repositories.mongo

import org.bson.Document
import org.springframework.core.convert.converter.Converter
import org.springframework.data.convert.ReadingConverter
import org.springframework.stereotype.Component
import java.time.ZoneId
import java.time.ZonedDateTime

@Component
@ReadingConverter
class ZonedDateTimeReadConverter : Converter<Document, ZonedDateTime> {
    override fun convert(document: Document): ZonedDateTime {

        if (document.containsKey(DATE_TIME) && document.containsKey(ZONE)) {
            val dateTime = document.getDate(DATE_TIME)
            val zone = document.getString(ZONE)
            return ZonedDateTime.ofInstant(dateTime.toInstant(), ZoneId.of(zone))
        } else {
            throw IllegalArgumentException("Document does not contain date and time information")
        }
    }

    companion object {
        const val DATE_TIME: String = "dateTime"
        const val ZONE: String = "zone"
    }
}
