import Flutter
import UIKit
import Vision
import VisionKit

@available(iOS 13.0, *)
public class CunningDocumentScannerPlugin: NSObject, FlutterPlugin, VNDocumentCameraViewControllerDelegate {
    var resultChannel: FlutterResult?
    var presentingController: VNDocumentCameraViewController?
    var scannerOptions = CunningScannerOptions()

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "cunning_document_scanner", binaryMessenger: registrar.messenger())
        let instance = CunningDocumentScannerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getPictures" else {
            result(FlutterMethodNotImplemented)
            return
        }

        scannerOptions = CunningScannerOptions.fromArguments(args: call.arguments)
        let presentedVC = UIApplication.shared.keyWindow?.rootViewController
        resultChannel = result

        if VNDocumentCameraViewController.isSupported {
            presentingController = VNDocumentCameraViewController()
            presentingController?.delegate = self
            presentedVC?.present(presentingController!, animated: true)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Document camera is not available on this device", details: nil))
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let tempDirPath = getDocumentsDirectory()
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        var filenames: [String] = []

        for i in 0 ..< scan.pageCount {
            let page = scan.imageOfPage(at: i)
            let url = tempDirPath.appendingPathComponent(formattedDate + "-\(i).\(scannerOptions.imageFormat.rawValue)")

            switch scannerOptions.imageFormat {
            case .jpg:
                try? page.jpegData(compressionQuality: scannerOptions.jpgCompressionQuality)?.write(to: url)
            case .png:
                try? page.pngData()?.write(to: url)
            }

            filenames.append(url.path)
        }

        resultChannel?(filenames)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        resultChannel?(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        presentingController?.dismiss(animated: true)
    }
}
