package at.sensatech.openfastlane.domain.repositories.mongo

import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.assertj.core.api.Assertions.assertThat
import org.bson.Document
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import java.time.ZoneId
import java.time.ZonedDateTime
import java.util.Date

class ZonedDateTimeReadConverterTest {

    private val subject = ZonedDateTimeReadConverter()

    private val date: Date = Date.from(ZonedDateTime.now().toInstant())

    private val document = mockk<Document> {
        every { containsKey(ZonedDateTimeReadConverter.DATE_TIME) } returns true
        every { containsKey(ZonedDateTimeReadConverter.ZONE) } returns true
        every { getDate(ZonedDateTimeReadConverter.DATE_TIME) } returns date
        every { getString(ZonedDateTimeReadConverter.ZONE) } returns "Europe/Vienna"
    }

    @Test
    fun `convert should return proper ZonedDateTime`() {

        val zone = ZoneId.of("Europe/Vienna")
        val ofInstant = ZonedDateTime.ofInstant(date.toInstant(), zone)

        val result = subject.convert(document)
        assertThat(result).isEqualTo(ofInstant)

        verify { document.containsKey(ZonedDateTimeReadConverter.DATE_TIME) }
        verify { document.containsKey(ZonedDateTimeReadConverter.ZONE) }
        verify { document.getDate(ZonedDateTimeReadConverter.DATE_TIME) }
        verify { document.getString(ZonedDateTimeReadConverter.ZONE) }
    }

    @Test
    fun `convert should return IllegalArgumentException when DATE_TIME is not used`() {

        val document = mockk<Document> {
            every { containsKey(ZonedDateTimeReadConverter.DATE_TIME) } returns false
            every { containsKey(ZonedDateTimeReadConverter.ZONE) } returns true
        }
        assertThrows<IllegalArgumentException> {
            subject.convert(document)
        }

        verify { document.containsKey(ZonedDateTimeReadConverter.DATE_TIME) }
    }

    @Test
    fun `convert should return IllegalArgumentException when ZONE is not used`() {

        val document = mockk<Document> {
            every { containsKey(ZonedDateTimeReadConverter.DATE_TIME) } returns true
            every { containsKey(ZonedDateTimeReadConverter.ZONE) } returns false
        }
        assertThrows<IllegalArgumentException> {
            subject.convert(document)
        }

        verify { document.containsKey(ZonedDateTimeReadConverter.ZONE) }
    }
}
