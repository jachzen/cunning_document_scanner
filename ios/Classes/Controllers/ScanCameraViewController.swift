//
//  NewCameraViewController.swift
//  WeScanSampleProject
//
//  Created by Chawatvish Worrapoj on 7/1/2020
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import UIKit
import WeScan

final class ScanCameraViewController: UIViewController {

    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var galleryButton: UIButton!
    @IBOutlet private weak var autoModeButton: UIButton!
    var controller: CameraScannerViewController!
    var isGalleryImportAllowed: Bool = false
    var isAutoScanEnabled: Bool = true
    var result: FlutterResult!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public func setParams(result: @escaping FlutterResult,  isGalleryImportAllowed: Bool = false, isAutoScanEnabled: Bool = true) {
        self.result = result
        self.isGalleryImportAllowed = isGalleryImportAllowed
        self.isAutoScanEnabled = isAutoScanEnabled
    }

    private func setupView() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        controller = CameraScannerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.view.frame = cameraView.bounds
        controller.willMove(toParent: self)
        cameraView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.delegate = self
        controller.isAutoScanEnabled = isAutoScanEnabled;
        galleryButton.isHidden = !isGalleryImportAllowed
        
        setAutoModeButtonView()
    }
    
    private func setAutoModeButtonView() {
        if(controller.isAutoScanEnabled) {
            autoModeButton.setTitle("Auto", for: .normal)
        } else {
            autoModeButton.setTitle("Manual", for: .normal)
        }
    }

    @IBAction func flashTapped(_ sender: UIButton) {
        controller.toggleFlash()
    }

    @IBAction func autoModeTapped(_ sender: UIButton) {
        controller.isAutoScanEnabled =  !controller.isAutoScanEnabled
        setAutoModeButtonView()
    }
    
    @IBAction func captureTapped(_ sender: UIButton) {
        controller.capture()
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        result(nil)
        self.dismiss(animated: true)
    }

    @IBAction func galleryTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true)
    }
    
    func pushEditDocumentViewController(image: UIImage, quad: Quadrilateral?){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "EditImageViewController") as? EditImageViewController
            else { return }
        controller.setParams(result: result, image: image, quad: quad)
        navigationController?.pushViewController(controller, animated: false)
    }
}

extension ScanCameraViewController: CameraScannerViewOutputDelegate {
    func captureImageFailWithError(error: Error) {
        print(error)
    }

    func captureImageSuccess(image: UIImage, withQuad quad: Quadrilateral?) {
        pushEditDocumentViewController(image: image, quad: quad)
    }
}


extension ScanCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        pushEditDocumentViewController(image: image, quad: nil)
    }
}
