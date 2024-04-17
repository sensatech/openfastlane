package at.sensatech.openfastlane.documents.exports

import at.sensatech.openfastlane.documents.FileResult

interface XlsExporter {

    fun export(exportSchema: ExportSchema, data: List<ExportLineItem>): FileResult?
}
