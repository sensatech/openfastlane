package at.sensatech.openfastlane.documents

import java.io.File

data class PdfResult(
    val name: String,
    val path: String,
    val file: File? = null
)
