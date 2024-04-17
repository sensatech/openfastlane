package at.sensatech.openfastlane.documents

import at.sensatech.openfastlane.domain.models.Entitlement
import at.sensatech.openfastlane.domain.models.Person
import com.lowagie.text.Chunk
import com.lowagie.text.Document
import com.lowagie.text.Font
import com.lowagie.text.FontFactory
import com.lowagie.text.Image
import com.lowagie.text.PageSize
import com.lowagie.text.Paragraph
import com.lowagie.text.Phrase
import com.lowagie.text.pdf.PdfPTable
import com.lowagie.text.pdf.PdfWriter
import org.slf4j.LoggerFactory
import java.io.File
import java.io.FileOutputStream
import java.nio.file.Path
import java.time.LocalDate
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlin.io.path.pathString

class OpenPdfGenerator(
    private val qrGenerator: QrGenerator
) : PdfGenerator {

    private val dateFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("dd.MM.YYYY")
    override fun createPersonEntitlementQrPdf(
        pdfInfo: PdfInfo,
        person: Person,
        entitlement: Entitlement,
        qrValue: String,
        campaignName: String?,
        entitlementName: String?,
    ): PdfResult? {

        try {
            val generateQrCode = qrGenerator.generateQrCode(qrValue)
            val document = Document(PageSize.A4)
            val fileOutputStream = FileOutputStream(pdfInfo.filename)
            val writer: PdfWriter = PdfWriter.getInstance(document, fileOutputStream)

            document.open()

            writeInfo(
                document,
                campaignName = campaignName,
                entitlementName = entitlementName,
                entitlementExpires = entitlement.expiresAt
            )
            if (generateQrCode != null) {
                writeTitle(document)
                writeQr(document, generateQrCode)
            }
            writePersonTable(document, person)
            document.close()
            writer.close()

            return PdfResult(
                pdfInfo.filename,
                pdfInfo.filename,
                File(pdfInfo.filename)
            )
        } catch (e: Exception) {
            log.error("Could not generate PDF: ", e)
        }

        return null
    }

    private fun writeTitle(
        document: Document,
    ) {
        val paragraph = Paragraph()
        val titleFont = Font(Font.HELVETICA, 14f, Font.BOLD)
        paragraph.setAlignment("Center")
        paragraph.spacingBefore = 30f
        paragraph.spacingBefore = 10f
        paragraph.add(Chunk("QR-Code für Bezugs- und Anspruchsprüfung:", titleFont))
        document.add(Paragraph(paragraph))
    }

    private fun writeInfo(
        document: Document,
        campaignName: String?,
        entitlementName: String?,
        entitlementExpires: ZonedDateTime?
    ) {
        val titleFont = Font(Font.HELVETICA, 16f)

        if (campaignName != null) {
            document.add(
                Paragraph().apply {
                    setAlignment("Center")
                    add(Chunk(campaignName, titleFont))
                }
            )
        }
        if (entitlementName != null) {
            document.add(
                Paragraph().apply {
                    setAlignment("Center")
                    add(Chunk(entitlementName, titleFont))
                }
            )
        }
        if (entitlementExpires != null) {
            val string = entitlementExpires.format(dateFormatter)
            document.add(
                Paragraph().apply {
                    setAlignment("Center")
                    add(Chunk("Gültig bis: $string", titleFont))
                }
            )
        }
    }

    private fun writeQr(document: Document, qrImagePath: Path) {
        val png: Image = Image.getInstance(qrImagePath.pathString)
        png.alignment = Image.ALIGN_CENTER
        png.scalePercent(80f)
        document.add(png)
    }

    private fun writePersonTable(
        document: Document,
        person: Person,
    ) {
        val width = document.pageSize.width

        val font8: Font = FontFactory.getFont(FontFactory.HELVETICA, 12f)
        val columnDefinitionSize = floatArrayOf(40f, 60f)

        val table = PdfPTable(columnDefinitionSize)

        table.defaultCell.border = 0
        table.widthPercentage = 50f
        table.totalWidth = width - 200
        table.isLockedWidth = true

//        table.addCell(Phrase("Anrede", font8))
//        table.addCell(addText(person.gender.toString(), font8))
        table.addCell(Phrase("Vorname:", font8))
        table.addCell(addText(person.firstName, font8))
        table.addCell(Phrase("Nachname:", font8))
        table.addCell(addText(person.lastName, font8))
        table.addCell(Phrase("Geburtsdatum:", font8))
        table.addCell(addText(person.dateOfBirth, font8))
        table.addCell(Phrase("Straße/Hausnummer:", font8))
        table.addCell(addText(person.address?.streetNameNumber, font8))
        table.addCell(Phrase("Stiege/Tür:", font8))
        table.addCell(addText(person.address?.addressSuffix, font8))
        table.addCell(Phrase("Postleitzahl:", font8))
        table.addCell(addText(person.address?.postalCode, font8))
        table.addCell(Phrase("E-Mail-Adresse:", font8))
        table.addCell(addText(person.email, font8))
        table.addCell(Phrase("Mobilnummer:", font8))
        table.addCell(addText(person.mobileNumber, font8))
        document.add(table)
    }

    private fun addText(value: Any?, font: Font): Phrase {
        val string = if (value is LocalDate) {
            value.format(dateFormatter)
        } else value?.toString()?.ifEmpty { "-" } ?: "-"
        return Phrase(string, font)
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
