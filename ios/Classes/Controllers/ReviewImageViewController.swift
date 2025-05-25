//
//  ReviewImageViewController.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import Foundation

final class ReviewImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var doneButton: UIBarButtonItem!
    var image: UIImage!
    
    weak var delegate: DocumentScannerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("review.title", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        doneButton.title = NSLocalizedString("review.button.done", bundle: Bundle(for: CunningDocumentScannerPlugin.self), comment: "Localizable")
        
        view.backgroundColor = SwiftCunningDocumentScannerPlugin.backgroundColor
        imageView.image = image
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        let filePath = FileUtils.saveImage(image: image)
        if let filePath = filePath {
            delegate?.documentScannerDidScan([filePath])
        } else {
            delegate?.documentScannerDidFail(withError: DocumentScannerError.savingFailed)
        }
    }
    
}
