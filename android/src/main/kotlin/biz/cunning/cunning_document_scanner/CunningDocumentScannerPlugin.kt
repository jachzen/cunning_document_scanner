package biz.cunning.cunning_document_scanner

import android.Manifest
import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import biz.cunning.cunning_document_scanner.fallback.DocumentScannerActivity
import biz.cunning.cunning_document_scanner.fallback.constants.DocumentScannerExtra
import com.google.mlkit.common.MlKitException
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.RESULT_FORMAT_JPEG
import com.google.mlkit.vision.documentscanner.GmsDocumentScannerOptions.SCANNER_MODE_FULL
import com.google.mlkit.vision.documentscanner.GmsDocumentScanning
import com.google.mlkit.vision.documentscanner.GmsDocumentScanningResult
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


/** CunningDocumentScannerPlugin */
class CunningDocumentScannerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    private var delegate: PluginRegistry.ActivityResultListener? = null
    private var binding: ActivityPluginBinding? = null
    private var pendingResult: Result? = null
    private lateinit var activity: Activity
    private val START_DOCUMENT_ACTIVITY: Int = 0x362738
    private val START_DOCUMENT_FB_ACTIVITY: Int = 0x362737
    private val REQUEST_CAMERA_PERMISSION: Int = 0x362739
    private var noOfPages: Int = 0


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
            noOfPages = call.argument<Int>("noOfPages") ?: 50;
            val isGalleryImportAllowed = call.argument<Boolean>("isGalleryImportAllowed") ?: false;
            this.pendingResult = result
            startScan(noOfPages, isGalleryImportAllowed)
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
        binding.addRequestPermissionsResultListener(this)
    }

    private fun addActivityResultListener(binding: ActivityPluginBinding) {
        this.binding = binding
        if (this.delegate == null) {
            this.delegate = PluginRegistry.ActivityResultListener { requestCode, resultCode, data ->
                if (requestCode != START_DOCUMENT_ACTIVITY && requestCode != START_DOCUMENT_FB_ACTIVITY) {
                    return@ActivityResultListener false
                }
                var handled = false
                if (requestCode == START_DOCUMENT_ACTIVITY) {
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            // check for errors
                            val error = data?.extras?.getString("error")
                            if (error != null) {
                                pendingResult?.error("ERROR", "error - $error", null)
                            } else {
                                // get an array with scanned document file paths
                                val scanningResult: GmsDocumentScanningResult =
                                    data?.extras?.getParcelable("extra_scanning_result")
                                        ?: return@ActivityResultListener false

                                val successResponse = scanningResult.pages?.map {
                                    it.imageUri.toString().removePrefix("file://")
                                }?.toList()
                                // trigger the success event handler with an array of cropped images
                                pendingResult?.success(successResponse)
                            }
                            handled = true
                        }

                        Activity.RESULT_CANCELED -> {
                            // user closed camera
                            pendingResult?.success(emptyList<String>())
                            handled = true
                        }
                    }
                } else {
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            // check for errors
                            val error = data?.extras?.getString("error")
                            if (error != null) {
                                pendingResult?.error("ERROR", "error - $error", null)
                            } else {
                                // get an array with scanned document file paths
                                val croppedImageResults =
                                    data?.getStringArrayListExtra("croppedImageResults")?.toList()
                                        ?: let {
                                            pendingResult?.error("ERROR", "No cropped images returned", null)
                                            return@ActivityResultListener true
                                        }

                                // return a list of file paths
                                // removing file uri prefix as Flutter file will have problems with it
                                val successResponse = croppedImageResults.map {
                                    it.removePrefix("file://")
                                }.toList()
                                // trigger the success event handler with an array of cropped images
                                pendingResult?.success(successResponse)
                            }
                            handled = true
                        }

                        Activity.RESULT_CANCELED -> {
                            // user closed camera
                            pendingResult?.success(emptyList<String>())
                            handled = true
                        }
                    }
                }

                if (handled) {
                    // Clear the pending result to avoid reuse
                    pendingResult = null
                }
                return@ActivityResultListener handled
            }
        } else {
            binding.removeActivityResultListener(this.delegate!!)
        }

        binding.addActivityResultListener(delegate!!)
    }


    /**
     * create intent to launch document scanner and set custom options
     */
    private fun createDocumentScanIntent(noOfPages: Int): Intent {
        val documentScanIntent = Intent(activity, DocumentScannerActivity::class.java)

        documentScanIntent.putExtra(
            DocumentScannerExtra.EXTRA_MAX_NUM_DOCUMENTS,
            noOfPages
        )

        return documentScanIntent
    }


    /**
     * add document scanner result handler and launch the document scanner
     */
    private fun startScan(noOfPages: Int, isGalleryImportAllowed: Boolean) {
        val options = GmsDocumentScannerOptions.Builder()
            .setGalleryImportAllowed(isGalleryImportAllowed)
            .setPageLimit(noOfPages)
            .setResultFormats(RESULT_FORMAT_JPEG)
            .setScannerMode(SCANNER_MODE_FULL)
            .build()
        val scanner = GmsDocumentScanning.getClient(options)
        scanner.getStartScanIntent(activity).addOnSuccessListener {
            try {
                // Use a custom request code for onActivityResult identification
                activity.startIntentSenderForResult(it, START_DOCUMENT_ACTIVITY, null, 0, 0, 0)

            } catch (e: IntentSender.SendIntentException) {
                pendingResult?.error("ERROR", "Failed to start document scanner", null)
            }
        }.addOnFailureListener {
            if (it is MlKitException) {
                if (ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.CAMERA
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    val intent = createDocumentScanIntent(noOfPages)
                    try {
                        ActivityCompat.startActivityForResult(
                            this.activity,
                            intent,
                            START_DOCUMENT_FB_ACTIVITY,
                            null
                        )
                    } catch (e: ActivityNotFoundException) {
                        pendingResult?.error("ERROR", "FAILED TO START ACTIVITY", null)
                    }
                } else {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(Manifest.permission.CAMERA),
                        REQUEST_CAMERA_PERMISSION
                    )
                }
            } else {
                pendingResult?.error("ERROR", "Failed to start document scanner Intent", null)
            }
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        addActivityResultListener(binding)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        removeActivityResultListener()
        binding?.removeRequestPermissionsResultListener(this)
    }

    private fun removeActivityResultListener() {
        this.delegate?.let { this.binding?.removeActivityResultListener(it) }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                val intent = createDocumentScanIntent(noOfPages)
                try {
                    ActivityCompat.startActivityForResult(
                        this.activity,
                        intent,
                        START_DOCUMENT_FB_ACTIVITY,
                        null
                    )
                } catch (e: ActivityNotFoundException) {
                    pendingResult?.error("ERROR", "FAILED TO START ACTIVITY", null)
                }
            } else {
                pendingResult?.error(
                    "CAMERA_PERMISSION_DENIED",
                    "Camera permission is required to scan documents.",
                    null
                )
            }
            return true
        }
        return false
    }
}
