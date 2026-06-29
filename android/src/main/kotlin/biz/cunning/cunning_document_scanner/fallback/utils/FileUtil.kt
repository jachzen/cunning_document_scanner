package biz.cunning.cunning_document_scanner.fallback.utils

import android.app.Activity
import android.graphics.BitmapFactory
import android.graphics.pdf.PdfDocument
import android.os.Environment
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.Date

/**
 * This class contains a helper function creating temporary files
 *
 * @constructor creates file util
 */
class FileUtil {
    /**
     * create a temporary file
     *
     * @param activity the current activity
     * @param pageNumber the current document page number
     */
    @Throws(IOException::class)
    fun createImageFile(activity: Activity, pageNumber: Int): File {
        // use current time to make file name more unique
        val dateTime: String = SimpleDateFormat(
            "yyyyMMdd_HHmmss",
            Locale.US
        ).format(Date())

        // create file in pictures directory
        val storageDir: File? = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile(
            "DOCUMENT_SCAN_${pageNumber}_${dateTime}",
            ".jpg",
            storageDir
        )
    }

    /**
     * create a temporary PDF file
     *
     * @param activity the current activity
     */
    @Throws(IOException::class)
    fun createPdfFile(activity: Activity): File {
        val dateTime: String = SimpleDateFormat(
            "yyyyMMdd_HHmmss",
            Locale.US
        ).format(Date())

        val storageDir: File? = activity.getExternalFilesDir(Environment.DIRECTORY_PICTURES)
        return File.createTempFile(
            "DOCUMENT_SCAN_${dateTime}",
            ".pdf",
            storageDir
        )
    }

    /**
     * convert a list of image file paths to a single PDF file
     *
     * @param imagePaths the list of paths to images
     * @param pdfFile the output PDF file
     */
    @Throws(IOException::class)
    fun convertImagesToPdf(imagePaths: List<String>, pdfFile: File) {
        val pdfDocument = PdfDocument()
        for ((index, imagePath) in imagePaths.withIndex()) {
            val bitmap = BitmapFactory.decodeFile(imagePath) ?: continue
            val pageInfo = PdfDocument.PageInfo.Builder(bitmap.width, bitmap.height, index + 1).create()
            val page = pdfDocument.startPage(pageInfo)
            val canvas = page.canvas
            canvas.drawBitmap(bitmap, 0f, 0f, null)
            pdfDocument.finishPage(page)
            bitmap.recycle()
        }
        FileOutputStream(pdfFile).use { out ->
            pdfDocument.writeTo(out)
        }
        pdfDocument.close()
    }
}