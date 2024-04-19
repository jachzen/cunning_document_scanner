//
//  EditScanViewController.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import Foundation
import WeScan

class EditImageViewController : UIViewController{
    @IBOutlet private weak var editImageView: UIView!
    @IBOutlet private weak var rotateButton: UIImageView!
    @IBOutlet private weak var nextButton: UIBarButtonItem!
    var result: FlutterResult!;
    var captureImage: UIImage!;
    var quad: Quadrilateral?
    var controller: WeScan.EditImageViewController!
    
    public func setParams(result: @escaping FlutterResult,  image: UIImage!, quad: Quadrilateral?) {
        self.result = result
        self.captureImage = image
        self.quad = quad
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        navigationItem.title = NSLocalizedString("edit.title", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        nextButton.title = NSLocalizedString("edit.button.next", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        
        self.view.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        editImageView.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        let imageForced = captureImage.forceSameOrientation()
        let orientedImage = UIImage(cgImage: imageForced.cgImage!, scale: imageForced.scale, orientation: .down)
        controller = WeScan.EditImageViewController(
            image: orientedImage,
            quad: quad,
            strokeColor: UIColor(red: (69.0 / 255.0), green: (194.0 / 255.0), blue: (177.0 / 255.0), alpha: 1.0).cgColor
        )
        controller.view.frame = editImageView.bounds
        controller.willMove(toParent: self)
        editImageView.addSubview(controller.view)
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.delegate = self
        
        rotateButton.tintColor = SwiftCunningDocumentScannerPlugin.tintColor
        rotateButton.isUserInteractionEnabled = true
        rotateButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rotateTapped)))
    }

    @IBAction func nextTapped(_ sender: UIButton!) {
        controller.cropImage()
    }
    

    @IBAction func rotateTapped(_ sender: UIButton!) {
        controller.rotateImage()
    }
    
    func pushReviewImageViewController(image: UIImage){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReviewImageViewController") as? ReviewImageViewController
            else { return }
        controller.setParams(result: result, image: image)
        navigationController?.pushViewController(controller, animated: false)
    }
}

extension EditImageViewController: EditImageViewDelegate {
    func cropped(image: UIImage) {
       pushReviewImageViewController(image: image)
    }
}
