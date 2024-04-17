package at.sensatech.openfastlane.server

import at.sensatech.openfastlane.documents.OpenPdfGenerator
import at.sensatech.openfastlane.documents.ZXQrGenerator
import at.sensatech.openfastlane.documents.exports.PoiXlsExporter
import at.sensatech.openfastlane.documents.exports.XlsExporter
import at.sensatech.openfastlane.documents.pdf.PdfGenerator
import at.sensatech.openfastlane.server.config.SimpleJsonObjectMapper
import com.fasterxml.jackson.databind.ObjectMapper
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
@EnableConfigurationProperties
class MainServerModule {

    @Bean
    fun objectMapper(): ObjectMapper {
        return SimpleJsonObjectMapper.create()
    }

    @Bean
    fun pdfGenerator(): PdfGenerator {
        return OpenPdfGenerator(ZXQrGenerator())
    }

    @Bean
    fun xlsExporter(): XlsExporter {
        return PoiXlsExporter()
    }
}
