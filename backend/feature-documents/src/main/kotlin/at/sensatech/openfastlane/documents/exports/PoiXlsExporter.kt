package at.sensatech.openfastlane.documents.exports

import at.sensatech.openfastlane.documents.FileResult
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.HorizontalAlignment
import org.apache.poi.ss.usermodel.Row
import org.apache.poi.ss.usermodel.Sheet
import org.apache.poi.xssf.usermodel.XSSFCellStyle
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileOutputStream
import java.time.LocalDate
import java.time.ZonedDateTime
import kotlin.math.max

class PoiXlsExporter(private val xssWorkbookCreator: XssWorkbookCreator) : XlsExporter {

    override fun export(exportSchema: ExportSchema, data: List<ExportLineItem>): FileResult {

        val causeIdSet = mutableSetOf<String>()
        data.forEach { item ->
            if (causeIdSet.contains(item.consumption.entitlementCauseId)) {
                return@forEach
            } else {
                causeIdSet.add(item.consumption.entitlementCauseId)
            }
        }

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
        val firstReportIndex = columns.size
        val (idMap, labelMap) = createReportIndexMap(exportSchema.reportColumns, firstReportIndex)

        // XLS tasks
        val workbook = xssWorkbookCreator.newWorkbook()

        val sheet: Sheet = workbook.createSheet(exportSchema.sheetName)

        val header: Row = sheet.createRow(0)
        val headerStyle = headerStyle(workbook)

        val textStyle = workbook.createCellStyle().apply { wrapText = true }
        val dateStyle = workbook.createCellStyle().apply { dataFormat = 14 }
        val dateTimeStyle = workbook.createCellStyle().apply { dataFormat = 22 }

        columns.forEachIndexed { index, item ->
            val headerCell: Cell = header.createCell(index)
            headerCell.setCellValue(item)
            headerCell.cellStyle = headerStyle

            val colWidth = 2000 + item.length * 300
            sheet.setColumnWidth(index, max(colWidth, 3500))
        }

        labelMap.forEach { (label, index) ->
            val headerCell: Cell = header.createCell(index)
            headerCell.setCellValue(label)
            headerCell.cellStyle = headerStyle

            val colWidth = 2000 + label.length * 300
            sheet.setColumnWidth(index, max(colWidth, 3500))
        }

        data.forEachIndexed { index, item ->
            val row: Row = sheet.createRow(index + 1)
            createCell(row, 0, item.person.firstName, textStyle)
            createCell(row, 1, item.person.lastName, textStyle)
            createCell(row, 2, item.person.dateOfBirth, dateStyle)
            createCell(row, 3, item.person.address?.streetNameNumber, textStyle)
            createCell(row, 4, item.person.address?.postalCode, textStyle)

            val campaignName = exportSchema.campaignNames[item.consumption.campaignId] ?: "..."
            val entitlementCauseName = exportSchema.causeNames[item.consumption.entitlementCauseId] ?: "..."
            createCell(row, 5, campaignName, textStyle)
            createCell(row, 6, entitlementCauseName, textStyle)

            createCell(row, 7, item.consumption.consumedAt, dateTimeStyle)

            idMap.forEach { (id, findIndex) ->
                if (item.consumption.entitlementData.any { it.criteriaId == id }) {
                    val entitlementValue = item.consumption.entitlementData.first { it.criteriaId == id }
                    val item1 = entitlementValue.value
                    createCell(row, findIndex, item1, textStyle)
                }
            }
        }

        val currDir = File(".")
        val path = currDir.absolutePath
        val fileLocation = path.substring(0, path.length - 1) + "temp.xlsx"

        val outputStream = FileOutputStream(fileLocation)
        workbook.write(outputStream)
        workbook.close()
        return FileResult(
            exportSchema.name,
            fileLocation,
            File(fileLocation)
        )
    }

    /**
     * transforms an ordered map of (id, label) to a map of (label, index) and (id, index)
     */
    fun createReportIndexMap(
        reportColumns: LinkedHashMap<String, String>,
        firstReportIndex: Int
    ): Pair<MutableMap<String, Int>, MutableMap<String, Int>> {
        val idMap = mutableMapOf<String, Int>()
        val labelMap = mutableMapOf<String, Int>()
        var index = 0
        reportColumns.entries.forEach { (id, reportKey) ->

            if (!labelMap.containsKey(reportKey)) {
                labelMap[reportKey] = firstReportIndex + index
                idMap[id] = firstReportIndex + index
                index++
            } else {
                idMap[id] = labelMap[reportKey]!!
            }
        }
        return idMap to labelMap
    }

    private fun createCell(row: Row, index: Int, item: Any?, style: XSSFCellStyle) {
        row.createCell(index).apply {
            when (item) {
                null -> setCellValue("")
                is LocalDate -> setCellValue(item)
                is ZonedDateTime -> setCellValue(item.toLocalDateTime())
                is Int -> setCellValue(item.toDouble())
                is String -> setCellValue(item)
                else -> setCellValue(item.toString())
            }
            cellStyle = style
        }
    }

    private fun headerStyle(workbook: XSSFWorkbook): XSSFCellStyle? {
        return workbook.createCellStyle().apply {
            fillPattern = FillPatternType.NO_FILL
            alignment = HorizontalAlignment.CENTER
            setFont(
                workbook.createFont().apply {
                    bold = true
                }
            )
        }
    }
}

class XssWorkbookCreator {
    fun newWorkbook(): XSSFWorkbook {
        return XSSFWorkbook()
    }
}
