//
//  ScanCameraViewController.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import UIKit
import WeScan
import SVGKit

final class ScanCameraViewController: UIViewController {

    @IBOutlet private weak var cameraView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var shutterView: UIView!
    @IBOutlet private weak var galleryButton: UIImageView!
    @IBOutlet private weak var autoModeSwitch: UISwitch!
    @IBOutlet private weak var autoModeLabel: UILabel!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    var controller: CameraScannerViewController!
    var isGalleryImportAllowed: Bool = false
    var isAutoScanEnabled: Bool = true
    var isAutoScanAllowed: Bool = true
    var isFlashAllowed: Bool = true
    var result: FlutterResult!;
    
    var flashEnabled = false;
    
    var oldAutoScanState = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    public func setParams(result: @escaping FlutterResult,  isGalleryImportAllowed: Bool, isAutoScanEnabled: Bool, isAutoScanAllowed: Bool, isFlashAllowed: Bool) {
        self.result = result
        self.isGalleryImportAllowed = isGalleryImportAllowed
        self.isAutoScanEnabled = isAutoScanEnabled
        self.isAutoScanAllowed = isAutoScanAllowed
        self.isFlashAllowed = isFlashAllowed
    }

    private func setupView() {
        navigationItem.title = NSLocalizedString("scan.title", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: SwiftCunningDocumentScannerPlugin.tintColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: SwiftCunningDocumentScannerPlugin.tintColor]
        navigationController?.navigationBar.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        navigationController?.view.tintColor = SwiftCunningDocumentScannerPlugin.tintColor
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        self.view.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        bottomView.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        
        setCameraView()
        setAutoModeButtonView()
        setGalleryButtonView()
        setFlashButtonView()
        setShutterButtonView()
        setBackButtonView()
    }
    
    private func setCameraView(){
        controller = CameraScannerViewController()
        controller.modalPresentationStyle = .fullScreen
        controller.view.frame = cameraView.bounds
        controller.willMove(toParent: self)
        cameraView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.delegate = self
        if(!isAutoScanAllowed){
            controller.isAutoScanEnabled = false;
        }else{
            controller.isAutoScanEnabled = isAutoScanEnabled;
        }
       
    }
    
    private func setAutoModeButtonView() {
        autoModeSwitch.tintColor = SwiftCunningDocumentScannerPlugin.tintColor
        autoModeSwitch.isHidden = !isAutoScanAllowed
        autoModeSwitch.isOn = controller.isAutoScanEnabled
        autoModeLabel.isHidden = !isAutoScanAllowed
        autoModeLabel.textColor = SwiftCunningDocumentScannerPlugin.tintColor
        
        if(controller.isAutoScanEnabled) {
            autoModeLabel.text = NSLocalizedString("scanning.auto", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        } else {
            autoModeLabel.text = NSLocalizedString("scanning.manual", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        }
    }
    
    private func setGalleryButtonView() {
        galleryButton.tintColor = SwiftCunningDocumentScannerPlugin.tintColor
        galleryButton.isHidden = !isGalleryImportAllowed
        galleryButton.isUserInteractionEnabled = true
        galleryButton.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action:#selector(galleryTapped)))
    }
    
    private func setFlashButtonView() {
        let imageOff = SVGKImage(named: "flash_off",in: Bundle(for: CunningDocumentScannerPlugin.self)).uiImage
        
        let imageOn = SVGKImage(named: "flash_on",in: Bundle(for: CunningDocumentScannerPlugin.self)).uiImage
        
        let flashButton = UIBarButtonItem()
        flashButton.image = flashEnabled ? imageOn : imageOff
        flashButton.target = self
        flashButton.action = #selector(flashTapped)
    
        if(isFlashAllowed){
           navigationItem.setRightBarButton(flashButton,animated: true)
        }
    }
    
    private func setBackButtonView() {
        backButton.title = NSLocalizedString("scanning.cancel", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
    }
    
    private func setShutterButtonView() {
        let shutterButton = ShutterButton(frame: shutterView.bounds)
        shutterButton.tintColor = SwiftCunningDocumentScannerPlugin.tintColor
        shutterButton.addTarget(self, action: #selector(captureTapped), for: .touchDown)
        shutterView.addSubview(shutterButton)
    }


    @IBAction func flashTapped(_ sender: UIButton) {
        controller.toggleFlash()
        flashEnabled = !flashEnabled
        setFlashButtonView()
    }

    @IBAction func autoModeTapped(_ sender: UISwitch) {
        controller.isAutoScanEnabled =  sender.isOn
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
        //Disable autoscan when open image picker
        oldAutoScanState = controller.isAutoScanEnabled;
        controller.isAutoScanEnabled = false
        
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
        //Restore autoscan state
        controller.isAutoScanEnabled = oldAutoScanState
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        //Restore autoscan state
        controller.isAutoScanEnabled = oldAutoScanState
        
        guard let image = info[.originalImage] as? UIImage else { return }
        pushEditDocumentViewController(image: image, quad: nil)
    }
}
