//
//  ScanPhotoViewController.swift
//  edge_detection
//
//  Created by Henry Leung on 3/9/2021.
//

import WeScan
import Flutter
import Foundation

class DocumentPhotoScanController: UIViewController, ImageScannerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var _result:FlutterResult?
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        _result!(nil)
        dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        let scannerVC = ImageScannerController(image: image)
        scannerVC.imageScannerDelegate = self
        
        if #available(iOS 13.0, *) {
            scannerVC.isModalInPresentation = true
            scannerVC.overrideUserInterfaceStyle = .dark
            scannerVC.view.backgroundColor = .black
        }
        present(scannerVC, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Temp fix for https://github.com/WeTransfer/WeScan/issues/320
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            let navigationBar = UINavigationBar()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            appearance.backgroundColor = .systemBackground
            navigationBar.standardAppearance = appearance;
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            let appearanceTB = UITabBarAppearance()
            appearanceTB.configureWithOpaqueBackground()
            appearanceTB.backgroundColor = .systemBackground
            UITabBar.appearance().standardAppearance = appearanceTB
            UITabBar.appearance().scrollEdgeAppearance = appearanceTB
        }
        
        if self.isBeingPresented {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true)
        }
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        print(error)
        _result!(nil)
        self.dismiss(animated: true)
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        
        
        let filePath = saveImage(image:results.doesUserPreferEnhancedScan ? results.enhancedScan!.image : results.croppedScan.image)
        var filenames: [String] = []
        if(filePath != nil){
            filenames.append(filePath!)
        }
        _result!(filenames)
        self.dismiss(animated: true)
    }
    
    
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        // Your ViewController is responsible for dismissing the ImageScannerController
        scanner.dismiss(animated: true)
        _result!(nil)
        self.dismiss(animated: true)
    }
    
    
    func saveImage(image: UIImage) -> String? {
        guard let data = image.pngData() else {
            return nil
        }
        
        let tempDirPath = getDocumentsDirectory()
        let currentDateTime = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd-HHmmss"
        let formattedDate = df.string(from: currentDateTime)
        let filePath = tempDirPath.appendingPathComponent(formattedDate + ".png")
     
        do {
            let fileManager = FileManager.default
            
            // Check if file exists
            if fileManager.fileExists(atPath: filePath.path) {
                // Delete file
                try fileManager.removeItem(atPath: filePath.path)
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        do {
            try data.write(to: filePath)
            return filePath.path
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
