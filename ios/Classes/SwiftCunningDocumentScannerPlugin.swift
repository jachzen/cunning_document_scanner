import Flutter
import UIKit
import Vision
import VisionKit

@available(iOS 13.0, *)
public class SwiftCunningDocumentScannerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftCunningDocumentScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let isGalleryImportAllowed = args["isGalleryImportAllowed"] as? Bool ?? false
    let isAutoScanEnabled = args["isAutoScanEnabled"] as? Bool ?? false
      
    if (call.method == "getPictures")
    {
     if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
         let storyboard = UIStoryboard(name: "DocumentScannerStoryboard", bundle:  Bundle(for: CunningDocumentScannerPlugin.self))
         guard let controller = storyboard.instantiateInitialViewController() as? UINavigationController else {
             result(nil)
             return
         }
         controller.modalPresentationStyle = .fullScreen
         (controller.viewControllers.first as? ScanCameraViewController)?.setParams(
            result: result,
            isGalleryImportAllowed: isGalleryImportAllowed,
            isAutoScanEnabled: isAutoScanEnabled
         )
         
         viewController.present(controller, animated: true, completion: nil)
     } else{
         result(nil)
     }
    }else{
        result(FlutterMethodNotImplemented)
    }
  }
}
