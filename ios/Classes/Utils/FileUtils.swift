//
//  FolderUtils.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import Foundation

class FileUtils{
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func saveImage(image: UIImage) -> String? {
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
            }
            else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        do {
            try data.write(to: filePath)
            return filePath.path
        }
        
        catch {
            print(error.localizedDescription)
            return nil
        }
    }

}
