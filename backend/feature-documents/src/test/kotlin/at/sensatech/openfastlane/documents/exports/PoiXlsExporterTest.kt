package at.sensatech.openfastlane.documents.exports

import at.sensatech.openfastlane.domain.models.EntitlementCriteriaType
import at.sensatech.openfastlane.domain.models.EntitlementValue
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.apache.poi.xssf.usermodel.XSSFRow
import org.apache.poi.xssf.usermodel.XSSFSheet
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class PoiXlsExporterTest {

    lateinit var subject: PoiXlsExporter

    val columns = listOf(
        "Vorname",
        "Nachname",
        "Geburtsdatum",
        "Adresse",
        "PLZ",
        "Kampagne",
        "Ansuchgrund",
        "Zeitpunkt"
    )

    val reportColumns = linkedMapOf(
        "criteriaId1" to "reportColumn1",
        "criteriaId2" to "reportColumn2",
        "criteriaId3" to "reportColumn2",
    )

    val data = listOf(
        mockExportLineItem("firstName1", "lastName1", reportColumns.keys),
        mockExportLineItem("firstName2", "lastName2", reportColumns.keys),
    )

    val headerRow = mockk<XSSFRow>(relaxed = true) {
        every { createCell(0) } returns mockk {
            every { setCellValue(any<String>()) } returns Unit
            every { cellStyle = any() } returns Unit
        }
        every { createCell(1) } returns mockk {
            every { setCellValue(any<String>()) } returns Unit
            every { cellStyle = any() } returns Unit
        }
    }
    val mockSheet: XSSFSheet = mockk(relaxed = true) {
        every { createRow(0) } returns headerRow
    }
    val mockWorkbook: XSSFWorkbook = mockk(relaxed = true) {
        every { createSheet("sheetname") } returns mockSheet
    }
    val creator: XssWorkbookCreator = mockk {
        every { newWorkbook() } returns mockWorkbook
    }

    val campaignNames: Map<String, String> = mockk {
        val it = this
        every { it.get("campaign1Id") } returns "campaign1Name"
        every { it.get("campaign2Id") } returns "campaign2Name"
    }
    val causesNames: Map<String, String> = mockk {
        val it = this
        every { it.get("cause1Id") } returns "cause1Name"
        every { it.get("cause2Id") } returns "cause2Name"
    }

    val exportSchema = ExportSchema("name", "sheetname", campaignNames, causesNames, reportColumns)

    @BeforeEach
    fun setUp() {
        subject = PoiXlsExporter(creator)
    }

    @Test
    fun `export should use exportSchema-sheetName`() {

        subject.export(exportSchema, data)

        verify { creator.newWorkbook() }
        verify { mockWorkbook.createSheet("sheetname") }
    }

    @Test
    fun `export should create headerRow with all columns and reportColumns`() {

        subject.export(exportSchema, data)

        verify { mockSheet.createRow(0) }
        val size = columns.size + reportColumns.size - 1
        verify(exactly = size) { headerRow.createCell(any()) }
    }

    @Test
    fun `export should print a row for each export line item person`() {

        subject.export(exportSchema, data)

        val rows = data.size + 1
        verify(exactly = rows) { mockSheet.createRow(any()) }
        verify { data[0].person.firstName }
        verify { data[0].person.lastName }
        verify { data[0].person.dateOfBirth }
        verify { data[0].person.address?.streetNameNumber }
        verify { data[0].person.address?.postalCode }
    }

    @Test
    fun `export should print a row for each export line item consumption, campaign and entitlementCause`() {

        subject.export(exportSchema, data)

        val rows = data.size + 1
        verify(exactly = rows) { mockSheet.createRow(any()) }
        verify { data[0].consumption.consumedAt }
        verify { data[0].consumption.campaignId }
        verify { data[0].consumption.entitlementCauseId }
    }

    @Test
    fun `createReportIndexMap should create an entry for each report Colum`() {
        val reportColumns = linkedMapOf(
            "criteriaId1" to "reportColumn1",
            "criteriaId2" to "reportColumn2",
            "criteriaId3" to "reportColumn2",
        )
        val (idMap, _) = subject.createReportIndexMap(reportColumns, 5)
        assert(idMap.size == reportColumns.size)
        assertThat(idMap).containsKeys("criteriaId1", "criteriaId2", "criteriaId3")
    }

    @Test
    fun `createReportIndexMap should have criterias with same report Key pointing to same index`() {
        val reportColumns = linkedMapOf(
            "criteriaId1" to "reportColumn1",
            "criteriaId2" to "reportColumn2",
            "criteriaId3" to "reportColumn2",
            "criteriaId4" to "reportColumn3",
            "criteriaId5" to "",
            "criteriaId6" to "reportColumn1",
            "criteriaId7" to "reportColumn4",
        )
        val (idMap, labelMap) = subject.createReportIndexMap(reportColumns, 5)
        assertThat(idMap["criteriaId1"]).isEqualTo(5)
        assertThat(idMap["criteriaId2"]).isEqualTo(6)
        assertThat(idMap["criteriaId3"]).isEqualTo(6)
        assertThat(idMap["criteriaId4"]).isEqualTo(7)
        assertThat(idMap["criteriaId6"]).isEqualTo(5)
        assertThat(idMap["criteriaId7"]).isEqualTo(9)

        assertThat(labelMap["reportColumn1"]).isEqualTo(5)
        assertThat(labelMap["reportColumn2"]).isEqualTo(6)
        assertThat(labelMap["reportColumn3"]).isEqualTo(7)
        assertThat(labelMap["reportColumn4"]).isEqualTo(9)

        assertThat(idMap["criteriaId5"]).isEqualTo(8)
        assertThat(labelMap[""]).isEqualTo(8)
    }

    private fun mockExportLineItem(firstName: String, lastName: String, keys: MutableSet<String>): ExportLineItem {
        return ExportLineItem(
            mockk(relaxed = true) {
                val person = this
                every { person.firstName } returns firstName
                every { person.lastName } returns lastName
            },
            mockk(relaxed = true) {
                val consumption = this
                every { consumption.entitlementData } returns keys.map {
                    EntitlementValue(it, EntitlementCriteriaType.TEXT, "value")
                }
                every { consumption.campaignId } returns "campaign1Id"
                every { consumption.entitlementCauseId } returns "cause1Id"
            }
        )
    }
}
