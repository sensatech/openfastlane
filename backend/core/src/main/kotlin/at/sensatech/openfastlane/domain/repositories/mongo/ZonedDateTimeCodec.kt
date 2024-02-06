package at.sensatech.openfastlane.domain.repositories.mongo

import org.bson.BsonReader
import org.bson.BsonWriter
import org.bson.codecs.Codec
import org.bson.codecs.DecoderContext
import org.bson.codecs.EncoderContext
import java.time.Instant
import java.time.ZoneId
import java.time.ZonedDateTime

class ZonedDateTimeCodec : Codec<ZonedDateTime> {
    override fun encode(writer: BsonWriter, value: ZonedDateTime, encoderContext: EncoderContext) {
        val epochMilli = value.toInstant().toEpochMilli()
        val zoneId = value.zone.id
        val transformed = "$epochMilli|$zoneId"
        return writer.writeString(transformed)
    }

    override fun decode(reader: BsonReader, decoderContext: DecoderContext): ZonedDateTime {
        val transformed = reader.readString()
        val split = transformed.split("|")
        if (split.size != 2) throw IllegalArgumentException("Invalid Id format")
        val epochMilli = split[0].toLong()
        val zoneId = split[1].toString()
        val instant = Instant.ofEpochMilli(epochMilli)
        val dateTime = ZonedDateTime.ofInstant(instant, ZoneId.of(zoneId))
        return dateTime
    }

    override fun getEncoderClass(): Class<ZonedDateTime> = ZonedDateTime::class.java
}
