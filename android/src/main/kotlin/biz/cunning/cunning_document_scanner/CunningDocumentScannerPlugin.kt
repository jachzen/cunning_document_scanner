package biz.cunning.cunning_document_scanner

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.app.ActivityCompat
import com.websitebeaver.documentscanner.DocumentScannerActivity
import com.websitebeaver.documentscanner.constants.DocumentScannerExtra
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** CunningDocumentScannerPlugin */
class CunningDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var delegate: PluginRegistry.ActivityResultListener? = null
    private var binding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private lateinit var activity: Activity

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
          val crop = call.argument<Boolean>("crop");
            if (crop != null) {
                this.pendingResult = result
                startScan(crop)
            } else {
                result.error("INVALID_ARGUMENT", "The value 'crop' is not a boolean", null)
            }
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
                if (requestCode != START_DOCUMENT_ACTIVITY) {
                    return@ActivityResultListener false
                }
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        // check for errors
                        val error = data?.extras?.getString("error")
                        if (error != null) {
                            throw Exception("error - $error")
                        }

                        // get an array with scanned document file paths
                        val croppedImageResults =
                            data?.getStringArrayListExtra("croppedImageResults")?.toList()
                                ?: throw Exception("No cropped images returned")

                        // return a list of file paths
                        // removing file uri prefix as Flutter file will have problems with it
                        val successResponse = croppedImageResults.map {
                            it.removePrefix("file://")
                        }.toList()

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
    private fun createDocumentScanIntent(crop: Boolean): Intent {
        val documentScanIntent = Intent(activity, DocumentScannerActivity::class.java)
        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_LET_USER_ADJUST_CROP,
            crop
        )
        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_MAX_NUM_DOCUMENTS,
        if(crop) 100 else 1
        )

        return documentScanIntent
    }


    /**
     * add document scanner result handler and launch the document scanner
     */
    private fun startScan(crop: Boolean) {
        val intent = createDocumentScanIntent(crop)
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

    companion object {
        private const val START_DOCUMENT_ACTIVITY: Int = 0x362738
    }
}
