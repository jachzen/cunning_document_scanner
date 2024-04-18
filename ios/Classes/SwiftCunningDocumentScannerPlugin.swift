import Flutter
import UIKit
import Vision
import VisionKit

@available(iOS 13.0, *)
public class SwiftCunningDocumentScannerPlugin: NSObject, FlutterPlugin {
    
    public static var backgroundColor: UIColor =  UIColor.white;
    public static var tintColor: UIColor =  UIColor.blue;
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftCunningDocumentScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as! Dictionary<String, Any>
    let isGalleryImportAllowed = args["isGalleryImportAllowed"] as? Bool ?? false
    let isAutoScanEnabled = args["isAutoScanEnabled"] as? Bool ?? false
    let isAutoScanAllowed = args["isAutoScanAllowed"] as? Bool ?? false
    let isFlashAllowed = args["isFlashAllowed"] as? Bool ?? false
    let backgroundColorInt = args["backgroundColor"] as? Int
    let tintColorInt = args["tintColor"] as? Int
    
      if(backgroundColorInt != nil){
          SwiftCunningDocumentScannerPlugin.backgroundColor = UIColor(hexa: backgroundColorInt!)
      }
      if(tintColorInt != nil){
          SwiftCunningDocumentScannerPlugin.tintColor = UIColor(hexa: tintColorInt!)
      }
    if (call.method == "getPictures")
    {
     if let viewController = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController {
         let storyboard = UIStoryboard(name: "DocumentScannerStoryboard", bundle:  Bundle(for: CunningDocumentScannerPlugin.self))
         guard let controller = storyboard.instantiateInitialViewController() as? UINavigationController else {
             result(nil)
             return
         }
         (controller.viewControllers.first as? ScanCameraViewController)?.setParams(
            result: result,
            isGalleryImportAllowed: isGalleryImportAllowed,
            isAutoScanEnabled: isAutoScanEnabled,
            isAutoScanAllowed: isAutoScanAllowed,
            isFlashAllowed: isFlashAllowed
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
