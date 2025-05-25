//
//  DocumentScannerDelegate.swift
//  cunning_document_scanner
//
//  Created on 5/25/2025.
//

import Foundation

protocol DocumentScannerDelegate: AnyObject {
    func documentScannerDidScan(_ images: [String])
    func documentScannerDidCancel()
    func documentScannerDidFail(withError error: Error)
}

enum DocumentScannerError: LocalizedError {
    case imageProcessingFailed
    case savingFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the scanned image"
        case .savingFailed:
            return "Failed to save the scanned document"
        case .unknown(let message):
            return message
        }
    }
}