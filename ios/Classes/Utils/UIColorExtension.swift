//
//  UIColorExtension.swift
//  cunning_document_scanner
//
//  Created by Romain Boucher on 18/04/2024.
//

import Foundation

extension UIColor{
    convenience init(hexa: Int) {
        self.init(red:   CGFloat((hexa & 0xFF0000)   >> 16)/255,
                  green: CGFloat((hexa & 0xFF00)     >> 8 )/255,
                  blue:  CGFloat((hexa & 0xFF)            )/255,
                  alpha: CGFloat((hexa & 0xFF000000) >> 24)/255)
    }
    
    var hexa: Int {
         var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
         getRed(&red, green: &green, blue: &blue, alpha: &alpha)
         return Int(alpha * 255) << 24
              + Int(red   * 255) << 16
              + Int(green * 255) << 8
              + Int(blue  * 255)
     }
}
