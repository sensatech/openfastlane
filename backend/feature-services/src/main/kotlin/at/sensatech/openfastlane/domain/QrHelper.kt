package at.sensatech.openfastlane.domain

import com.google.zxing.BarcodeFormat
import com.google.zxing.client.j2se.MatrixToImageWriter
import com.google.zxing.qrcode.QRCodeWriter
import org.springframework.stereotype.Service
import java.awt.image.BufferedImage

@Service
class QrHelper {
    fun generateQrCode(value: String): BufferedImage? {
        val barcodeWriter = QRCodeWriter()
        val bitMatrix = barcodeWriter.encode(value, BarcodeFormat.QR_CODE, 400, 400)
        return MatrixToImageWriter.toBufferedImage(bitMatrix)
    }
}
