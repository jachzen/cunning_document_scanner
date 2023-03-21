import Flutter
import UIKit
import Vision
import VisionKit

@available(iOS 13.0, *)
public class SwiftCunningDocumentScannerPlugin: NSObject, FlutterPlugin, MyDocumentCameraViewControllerDelegate {
   var resultChannel :FlutterResult?
   var presentingController: MyDocumentCameraViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
    let instance = SwiftCunningDocumentScannerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPictures" {
            let presentedVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
            self.resultChannel = result
            self.presentingController = MyDocumentCameraViewController()
            self.presentingController!.delegate = self
            presentedVC?.present(self.presentingController!, animated: true)
        } else {
            result(FlutterMethodNotImplemented)
            return
        }
  }


    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func documentCameraViewController(_ controller: MyDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let tempDirPath = self.getDocumentsDirectory()
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        var filenames: [String] = []
        for i in 0 ... scan.pageCount - 1 {
            let page = scan.imageOfPage(at: i)
            let url = tempDirPath.appendingPathComponent(formattedDate + "-\(i).png")
            try? page.pngData()?.write(to: url)
            filenames.append(url.path)
        }
        resultChannel?(filenames)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewControllerDidCancel(_ controller: MyDocumentCameraViewController) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewController(_ controller: MyDocumentCameraViewController, didFailWithError error: Error) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }
}


class MyDocumentCameraViewController: VNDocumentCameraViewController {
    override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Place the photo in view"
}
}