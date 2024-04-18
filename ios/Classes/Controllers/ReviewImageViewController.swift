//
//  ReviewImageViewController.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import Foundation

final class ReviewImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    var image: UIImage!
    var result: FlutterResult!

    public func setParams(result: @escaping FlutterResult,  image: UIImage!) {
        self.result = result
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Review"
        
        view.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        imageView.image = image
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        let filePath = FileUtils.saveImage(image: image)
        if(filePath != nil){
            result([filePath])
        }else{
            result(nil)
        }
        self.dismiss(animated: true)
    }
    
}
