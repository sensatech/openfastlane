package at.sensatech.openfastlane.documents.exports

import at.sensatech.openfastlane.documents.FileResult
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.Row
import org.apache.poi.ss.usermodel.Sheet
import org.apache.poi.xssf.usermodel.XSSFCellStyle
import org.apache.poi.xssf.usermodel.XSSFFont
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileOutputStream
import java.time.LocalDate
import java.time.ZonedDateTime

class PoiXlsExporter : XlsExporter {

    override fun export(exportSchema: ExportSchema, data: List<ExportLineItem>): FileResult {

        val workbook = XSSFWorkbook()

        val sheet: Sheet = workbook.createSheet(exportSchema.sheetName)
        sheet.setColumnWidth(0, 6000)
        sheet.setColumnWidth(1, 4000)

        val causeIdSet = mutableSetOf<String>()
        data.forEach { item ->
            if (causeIdSet.contains(item.consumption.entitlementCauseId)) {
                return@forEach
            } else {
                causeIdSet.add(item.consumption.entitlementCauseId)
            }
        }
        val header: Row = sheet.createRow(0)

        val headerStyle = headerStyle(workbook)

        exportSchema.columns.forEachIndexed { index, item ->
            val headerCell: Cell = header.createCell(index)
            headerCell.setCellValue(item)
            headerCell.cellStyle = headerStyle
        }

        val firstReportIndex = exportSchema.columns.size
        val reportIndexes = mutableMapOf<String, Int>()

        exportSchema.reportColumns.entries.forEachIndexed { index, mutableEntry ->
            val headerCell: Cell = header.createCell(firstReportIndex + index)
            headerCell.setCellValue(mutableEntry.value)
            headerCell.cellStyle = headerStyle
            reportIndexes[mutableEntry.key] = firstReportIndex + index
        }

        val textStyle = workbook.createCellStyle().apply { wrapText = true }
        val dateStyle = workbook.createCellStyle().apply { dataFormat = 14 }
        val dateTimeStyle = workbook.createCellStyle().apply { dataFormat = 22 }

        data.forEachIndexed { index, item ->
            val row: Row = sheet.createRow(index + 1)
            createCell(row, 0, item.person.firstName, textStyle)
            createCell(row, 1, item.person.lastName, textStyle)
            createCell(row, 2, item.person.dateOfBirth, dateStyle)
            createCell(row, 3, item.person.address?.streetNameNumber, textStyle)
            createCell(row, 4, item.person.address?.postalCode, textStyle)
            createCell(row, 5, item.consumption.consumedAt, dateTimeStyle)

            reportIndexes.forEach { (id, findIndex) ->
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
            "export.xlsx",
            fileLocation,
            File(fileLocation)
        )
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
            fillPattern = FillPatternType.SOLID_FOREGROUND
            setFont(headerFont(workbook))
        }
    }

    private fun headerFont(workbook: XSSFWorkbook): XSSFFont? {
        return workbook.createFont().apply {
            fontName = "Arial"
            fontHeightInPoints = 16.toShort()
            bold = true
        }
    }
}
