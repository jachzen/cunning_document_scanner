extension UIImage {
    func forceSameOrientation() -> UIImage {
         UIGraphicsBeginImageContext(self.size)
         self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
         guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
             UIGraphicsEndImageContext()
             return self
         }
         UIGraphicsEndImageContext()
         return image
     }
}
