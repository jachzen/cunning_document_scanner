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
        navigationItem.title = "Edit"
        
        self.view.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        editImageView.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        
        controller = WeScan.EditImageViewController(
            image: captureImage,
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

    @IBAction func cropTapped(_ sender: UIButton!) {
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
