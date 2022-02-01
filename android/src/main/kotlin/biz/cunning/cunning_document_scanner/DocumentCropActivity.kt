package biz.cunning.cunning_document_scanner

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import android.os.Bundle
import android.view.View
import android.widget.ProgressBar
import androidx.fragment.app.FragmentActivity
import biz.cunning.cunning_document_scanner.DocumentCropActivity.DocumentCropConst.CROPPED_IMAGE
import biz.cunning.cunning_document_scanner.DocumentCropActivity.DocumentCropConst.TAKE_MORE
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.labters.documentscanner.DocumentScannerView
import java.io.FileOutputStream
import java.io.IOException
import java.lang.Exception

class DocumentCropActivity : FragmentActivity() {
    object DocumentCropConst {
        val CROPPED_IMAGE = "CROPPED_IMAGE"
        val TAKE_MORE = "TAKE_MORE"
    }

    override fun onBackPressed() {
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.document_cropper)

        val documentScannerView: DocumentScannerView = findViewById(R.id.document_scanner)
        val progressBar: ProgressBar = findViewById(R.id.progressBar)
        val bottomNavigation: BottomNavigationView = findViewById(R.id.navigation_bar)

        val filePath = intent.extras!!["CROP_IMAGE"] as String?
        this.title = ""
        progressBar.visibility = View.VISIBLE

        //this.getOnBackPressedDispatcher().;
        val options = BitmapFactory.Options()
        options.inPreferredConfig = Bitmap.Config.ARGB_8888
        var bitmap = BitmapFactory.decodeFile(filePath, options)
        bitmap = autoRotatePicture(filePath, bitmap)
        documentScannerView.setOnLoadListener {
            progressBar.visibility = View.GONE
        }
        documentScannerView.setImage(bitmap!!)
        bottomNavigation.itemIconTintList = null;
        bottomNavigation.setOnNavigationItemSelectedListener { item ->
            when (item.itemId) {
                R.id.add_picture -> {
                    progressBar.visibility = View.VISIBLE
                    saveImage(documentScannerView, filePath!!)
                    progressBar.visibility = View.GONE
                    intent.putExtra(CROPPED_IMAGE, filePath)
                    intent.putExtra(TAKE_MORE, true)
                    setResult(Activity.RESULT_OK, intent);
                    this.finish()
                }
                R.id.finish -> {
                    progressBar.visibility = View.VISIBLE
                    saveImage(documentScannerView, filePath!!)
                    progressBar.visibility = View.GONE
                    intent.putExtra(CROPPED_IMAGE, filePath)
                    intent.putExtra(TAKE_MORE, false)
                    setResult(Activity.RESULT_OK, intent);
                    this.finish()
                }
            }
            true
        }
    }

    private fun saveImage(documentScannerView: DocumentScannerView, filePath: String) {
        val bitmap = documentScannerView.getCroppedImage()
        try {
            FileOutputStream(filePath).use { out ->
                bitmap.compress(
                    Bitmap.CompressFormat.PNG,
                    100,
                    out
                ) // bmp is your Bitmap instance
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun resize(image: Bitmap, maxWidth: Int, maxHeight: Int): Bitmap? {
        var image = image
        return if (maxHeight > 0 && maxWidth > 0) {
            val width = image.width
            val height = image.height
            val ratioBitmap = width.toFloat() / height.toFloat()
            val ratioMax = maxWidth.toFloat() / maxHeight.toFloat()
            var finalWidth = maxWidth
            var finalHeight = maxHeight
            if (ratioMax > ratioBitmap) {
                finalWidth = (maxHeight.toFloat() * ratioBitmap).toInt()
            } else {
                finalHeight = (maxWidth.toFloat() / ratioBitmap).toInt()
            }
            image = Bitmap.createScaledBitmap(image, finalWidth, finalHeight, true)
            image
        } else {
            image
        }
    }

    private fun autoRotatePicture(filePath: String?, bitmap: Bitmap?): Bitmap? {
        return try {
            val scaledBitmap = resize(bitmap!!, 1600, 1600)
            val ei = ExifInterface(filePath!!)
            val orientation = ei.getAttributeInt(
                ExifInterface.TAG_ORIENTATION,
                ExifInterface.ORIENTATION_UNDEFINED
            )
            var rotatedBitmap: Bitmap? = null
            rotatedBitmap =
                when (orientation) {
                    ExifInterface.ORIENTATION_ROTATE_90 -> rotateImage(scaledBitmap, 90f)
                    ExifInterface.ORIENTATION_ROTATE_180 -> rotateImage(scaledBitmap, 180f)
                    ExifInterface.ORIENTATION_ROTATE_270 -> rotateImage(scaledBitmap, 270f)
                    ExifInterface.ORIENTATION_NORMAL -> scaledBitmap
                    else -> scaledBitmap
                }
            rotatedBitmap
        } catch (e: Exception) {
            bitmap
        }
    }

    companion object {
        fun rotateImage(source: Bitmap?, angle: Float): Bitmap {
            val matrix = Matrix()
            matrix.postRotate(angle)
            return Bitmap.createBitmap(
                source!!, 0, 0, source.width, source.height,
                matrix, true
            )
        }
    }
}
