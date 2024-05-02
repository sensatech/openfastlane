package at.sensatech.openfastlane.documents

import java.io.File

data class FileResult(
    val name: String,
    val path: String,
    val file: File? = null
)
