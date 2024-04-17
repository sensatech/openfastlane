package at.sensatech.openfastlane.documents

import java.nio.file.Path

interface QrGenerator {
    fun generateQrCode(value: String): Path?
}
