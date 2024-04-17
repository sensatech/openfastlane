package at.sensatech.openfastlane.documents

import com.google.zxing.BarcodeFormat
import com.google.zxing.client.j2se.MatrixToImageWriter
import com.google.zxing.qrcode.QRCodeWriter
import org.slf4j.LoggerFactory
import java.nio.file.Path
import kotlin.io.path.Path

class ZXQrGenerator : QrGenerator {

    override fun generateQrCode(value: String): Path? {
        try {
            val barcodeWriter = QRCodeWriter()
            val bitMatrix = barcodeWriter.encode(value, BarcodeFormat.QR_CODE, 400, 400)
            val path = Path("tmp.png")
            MatrixToImageWriter.writeToPath(bitMatrix, "PNG", path)
            return path
        } catch (e: Exception) {
            log.error("Could not generate QR Code for value $value:", e)
            return null
        }
    }

    companion object {
        private val log = LoggerFactory.getLogger(this::class.java)
    }
}
