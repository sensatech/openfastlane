package at.sensatech.openfastlane.documents.exports

data class ExportSchema(
    val name: String,
    val sheetName: String,
    val columns: List<String>,
    val reportColumns: LinkedHashMap<String, String>,
)
