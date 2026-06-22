import Foundation

enum CunningScannerImageFormat: String {
    case jpg
    case png
}

struct CunningScannerOptions {
    let imageFormat: CunningScannerImageFormat
    let jpgCompressionQuality: Double

    init() {
        self.imageFormat = .png
        self.jpgCompressionQuality = 1.0
    }

    init(imageFormat: CunningScannerImageFormat, jpgCompressionQuality: Double) {
        self.imageFormat = imageFormat
        self.jpgCompressionQuality = jpgCompressionQuality
    }

    static func fromArguments(args: Any?) -> CunningScannerOptions {
        guard
            let arguments = args as? [String: Any],
            let scannerOptionsDict = arguments["iosScannerOptions"] as? [String: Any]
        else {
            return CunningScannerOptions()
        }

        let imageFormat = (scannerOptionsDict["imageFormat"] as? String) ?? "png"
        let jpgCompressionQuality = (scannerOptionsDict["jpgCompressionQuality"] as? Double) ?? 1.0

        return CunningScannerOptions(
            imageFormat: CunningScannerImageFormat(rawValue: imageFormat) ?? .png,
            jpgCompressionQuality: jpgCompressionQuality
        )
    }
}
