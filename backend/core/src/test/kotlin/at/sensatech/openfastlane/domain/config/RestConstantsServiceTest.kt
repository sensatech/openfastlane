package at.sensatech.openfastlane.domain.config

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows

internal class RestConstantsServiceTest {

    private lateinit var subject: RestConstantsService

    @Test
    fun `getRootUrl should return url without slash`() {
        subject = RestConstantsService("https://ofl.example.com/")
        val result = subject.getRootUrl()
        assertThat(result).isEqualTo("https://ofl.example.com/")
    }

    @Test
    fun `getRootUrl should throw for localhost url without slash`() {
        subject = RestConstantsService("http://localhost:8080/")
        assertThrows<IllegalStateException> {
            subject.getRootUrl()
        }
    }
}
