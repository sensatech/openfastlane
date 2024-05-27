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

    val columns = listOf("column1", "column2")
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
            every { setCellValue("column1") } returns Unit
            every { cellStyle = any() } returns Unit
        }
        every { createCell(1) } returns mockk {
            every { setCellValue("column2") } returns Unit
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

    @BeforeEach
    fun setUp() {
        subject = PoiXlsExporter(creator)
    }

    @Test
    fun `export should use exportSchema-sheetName`() {

        subject.export(ExportSchema("name", "sheetname", columns, reportColumns), data)

        verify { creator.newWorkbook() }
        verify { mockWorkbook.createSheet("sheetname") }
    }

    @Test
    fun `export should create headerRow with all columns and reportColumns`() {

        subject.export(ExportSchema("name", "sheetname", columns, reportColumns), data)

        verify { mockSheet.createRow(0) }
        val size = columns.size + reportColumns.size - 1
        verify(exactly = size) { headerRow.createCell(any()) }
    }

    @Test
    fun `export should a row for each export line item`() {

        subject.export(ExportSchema("name", "sheetname", columns, reportColumns), data)

        val rows = data.size + 1
        verify(exactly = rows) { mockSheet.createRow(any()) }
        verify { data[0].person.firstName }
        verify { data[0].person.lastName }
        verify { data[0].person.dateOfBirth }
        verify { data[0].person.address?.streetNameNumber }
        verify { data[0].person.address?.postalCode }
        verify { data[0].consumption.consumedAt }
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
            }
        )
    }
}
