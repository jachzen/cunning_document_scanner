package biz.cunning.cunning_document_scanner.fallback.utils

import android.os.Environment
import androidx.activity.ComponentActivity
import java.io.File
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
    fun createImageFile(activity: ComponentActivity, pageNumber: Int): File {
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
}