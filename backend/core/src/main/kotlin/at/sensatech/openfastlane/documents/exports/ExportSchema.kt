package at.sensatech.openfastlane.documents.exports

data class ExportSchema(
    val name: String,
    val sheetName: String,
    val campaignNames: Map<String, String>,
    val causeNames: Map<String, String>,
    val reportColumns: LinkedHashMap<String, String>,
)
