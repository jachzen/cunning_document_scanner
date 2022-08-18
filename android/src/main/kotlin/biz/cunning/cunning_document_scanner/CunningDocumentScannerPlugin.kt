package biz.cunning.cunning_document_scanner

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.ActivityNotFoundException
import android.content.Intent
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.FileProvider
import biz.cunning.cunning_document_scanner.DocumentCropActivity.DocumentCropConst.CROPPED_IMAGE
import biz.cunning.cunning_document_scanner.DocumentCropActivity.DocumentCropConst.TAKE_MORE
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

/** CunningDocumentScannerPlugin */
class CunningDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var file: File? = null
    private var pendingResult: Result? = null
    private lateinit var activity: Activity
    private val START_CAMERA_ACTIVITY = 1
    private val START_DOCUMENT_ACTIVITY = 2

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cunning_document_scanner")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPictures") {
            this.pictures.clear()
            this.pendingResult = result
            startCamera()
        } else {
            result.notImplemented()
        }
    }

    private fun startCamera() {
        file = createImageFile()
        file?.also {
            val takePictureIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
            val photoURI = FileProvider.getUriForFile(
                activity,
                activity.getPackageName() + ".flutter.cunning_document_scanner",
                it
            )
            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
            try {
                ActivityCompat.startActivityForResult(
                    this.activity,
                    takePictureIntent,
                    START_CAMERA_ACTIVITY,
                    null
                )
            } catch (e: ActivityNotFoundException) {
                // display error state to the user
            }
        }
    }

    lateinit var currentPhotoPath: String

    @Throws(IOException::class)
    private fun createImageFile(): File {
        val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val storageDir: File? = this.activity.cacheDir
        return File.createTempFile(
            "JPEG_${timeStamp}_",
            ".jpg",
            storageDir
        ).apply {
            currentPhotoPath = absolutePath
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity;

        addActivityResultListener(binding)
    }

    var pictures = mutableListOf<String>()

    private fun addActivityResultListener(binding: ActivityPluginBinding) {
        binding.addActivityResultListener { requestCode, resultCode, data ->
            if (resultCode == RESULT_OK)
                if (requestCode == START_CAMERA_ACTIVITY) {
                    startDocumentCropper()
                } else if (requestCode == START_DOCUMENT_ACTIVITY) {
                    if (data?.getStringExtra(CROPPED_IMAGE) == null) {
                        startCamera()
                    } else if (data != null && data!!.getBooleanExtra(TAKE_MORE, false)) {
                        val imagePath = data?.getStringExtra(CROPPED_IMAGE)
                        pictures.add(imagePath!!)
                        startCamera()
                    } else {
                        val imagePath = data?.getStringExtra(CROPPED_IMAGE)
                        pictures.add(imagePath!!)
                        this.pendingResult?.success(pictures)
                    }
                } else {
                    pendingResult?.error("INTENT_ERROR", "Intent request code unknown", null)
                }
            else {
                pendingResult?.error("INTENT_ERROR", "Intent not successfull", null)
            }
            true
        }
    }

    private fun startDocumentCropper() {
        val cropImageIntent = Intent(this.activity, DocumentCropActivity::class.java).apply {
            putExtra("CROP_IMAGE", file?.path)
        }
        try {
            ActivityCompat.startActivityForResult(
                this.activity,
                cropImageIntent,
                START_DOCUMENT_ACTIVITY,
                null
            )
        } catch (e: ActivityNotFoundException) {
            pendingResult?.error("ERROR", "FAILED TO START ACTIVITY", null)
        }

    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        addActivityResultListener(binding)
    }

    override fun onDetachedFromActivity() {

    }
}
