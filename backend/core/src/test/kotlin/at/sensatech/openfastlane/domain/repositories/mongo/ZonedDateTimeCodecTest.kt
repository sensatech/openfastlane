package at.sensatech.openfastlane.domain.repositories.mongo

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.bson.BsonReader
import org.bson.BsonWriter
import org.bson.codecs.DecoderContext
import org.bson.codecs.EncoderContext
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.ZonedDateTime

class ZonedDateTimeCodecTest {

    private val subject = ZonedDateTimeCodec()

    private val bsonReader: BsonReader = mockk()
    private val bsonWriter: BsonWriter = mockk(relaxed = true)
    private val encoderContext: EncoderContext = mockk()
    private val decoderContext: DecoderContext = mockk()

    @Test
    fun `encode should call bson writer`() {
        val now = ZonedDateTime.now()
        subject.encode(bsonWriter, now, encoderContext)

        val epochMilli = now.toInstant().toEpochMilli()
        val zoneId = now.zone.id
        val transformed = "$epochMilli|$zoneId"

        verify { bsonWriter.writeString(eq(transformed)) }
    }

    @Test
    fun `decode should return valid ZonedDateTime with matching millis and ignored nanos`() {

        val now = ZonedDateTime.now().withNano(2_000_345)

        val epochMilli = now.toInstant().toEpochMilli()
        val zoneId = now.zone.id
        val transformed = "$epochMilli|$zoneId"

        every { bsonReader.readString() } returns transformed

        val result = subject.decode(bsonReader, decoderContext)

        assertThat(result).isEqualTo(now.withNano(2_000_000))
    }

    @Test
    fun `decode should throw IllegalArgumentException if split size is wrong`() {
        val now = ZonedDateTime.now().withNano(2_000_345)

        val epochMilli = now.toInstant().toEpochMilli()
        val transformed = "$epochMilli"

        every { bsonReader.readString() } returns transformed

        assertThrows<IllegalArgumentException> {
            subject.decode(bsonReader, decoderContext)
        }
    }
}
