package biz.cunning.cunning_document_scanner

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.app.ActivityCompat
import com.websitebeaver.documentscanner.DocumentScannerActivity
import com.websitebeaver.documentscanner.constants.DefaultSetting
import com.websitebeaver.documentscanner.constants.DocumentScannerExtra
import com.websitebeaver.documentscanner.constants.ResponseType
import com.websitebeaver.documentscanner.utils.ImageUtil
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.io.File

/** CunningDocumentScannerPlugin */
class CunningDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var delegate: PluginRegistry.ActivityResultListener? = null
    private var binding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private lateinit var activity: Activity
    private var responseType: String? = DefaultSetting.RESPONSE_TYPE
    private val START_DOCUMENT_ACTIVITY: Int = 0x362738

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "cunning_document_scanner")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPictures") {
            this.pendingResult = result
            startScan()
        } else {
            result.notImplemented()
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity

        addActivityResultListener(binding)
    }

    private fun addActivityResultListener(binding: ActivityPluginBinding) {
        this.binding = binding
        if (this.delegate == null) {
            this.delegate = PluginRegistry.ActivityResultListener { requestCode, resultCode, data ->
                    // make sure responseType is valid
                    if (!arrayOf(
                            ResponseType.BASE64,
                            ResponseType.IMAGE_FILE_PATH
                        ).contains(responseType)) {
                        throw Exception("responseType must be either ${ResponseType.BASE64} " +
                                "or ${ResponseType.IMAGE_FILE_PATH}")
                    }
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            // check for errors
                            val error = data?.extras?.get("error") as String?
                            if (error != null) {
                                throw Exception("error - $error")
                            }

                            // get an array with scanned document file paths
                            val croppedImageResults: ArrayList<String> =
                                data?.getStringArrayListExtra(
                                    "croppedImageResults"
                                ) ?: throw Exception("No cropped images returned")

                            // if responseType is imageFilePath return an array of file paths
                            var successResponse: ArrayList<String> = croppedImageResults

                            // if responseType is base64 return an array of base64 images
                            if (responseType == ResponseType.BASE64) {
                                val base64CroppedImages =
                                    croppedImageResults.map { croppedImagePath ->
                                        // read cropped image from file path, and convert to base 64
                                        val base64Image = ImageUtil().readImageAndConvertToBase64(
                                            croppedImagePath
                                        )

                                        // delete cropped image from android device to avoid
                                        // accumulating photos
                                        File(croppedImagePath).delete()

                                        base64Image
                                    }

                                successResponse = base64CroppedImages as ArrayList<String>
                            }

                            // trigger the success event handler with an array of cropped images
                            this.pendingResult?.success(successResponse)
                            return@ActivityResultListener true
                        }
                        Activity.RESULT_CANCELED -> {
                            // user closed camera
                            this.pendingResult?.success(emptyList<String>())
                            return@ActivityResultListener true
                        }
                        else -> {
                            return@ActivityResultListener false
                        }
                    }
            }
        } else {
            binding.removeActivityResultListener(this.delegate!!)
        }

        binding.addActivityResultListener(delegate!!)
    }


    /**
     * create intent to launch document scanner and set custom options
     */
    fun createDocumentScanIntent(): Intent {
        val documentScanIntent = Intent(activity, DocumentScannerActivity::class.java)
        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_LET_USER_ADJUST_CROP,
            true
        )
        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_MAX_NUM_DOCUMENTS,
            100
        )

        return documentScanIntent
    }


    /**
     * add document scanner result handler and launch the document scanner
     */
    fun startScan() {
        val intent = createDocumentScanIntent()
        try {
            ActivityCompat.startActivityForResult(
                this.activity,
                intent,
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
        removeActivityResultListener()
    }

    private fun removeActivityResultListener() {
        this.delegate?.let { this.binding?.removeActivityResultListener(it) }
    }
}
