import Foundation

enum CunningScannerImageFormat: String {
    case jpg
    case png
}

struct CunningScannerOptions {
    let imageFormat: CunningScannerImageFormat
    let jpgCompressionQuality: Double
    let asPdf: Bool

    init() {
        self.imageFormat = .png
        self.jpgCompressionQuality = 1.0
        self.asPdf = false
    }

    init(imageFormat: CunningScannerImageFormat, jpgCompressionQuality: Double, asPdf: Bool) {
        self.imageFormat = imageFormat
        self.jpgCompressionQuality = jpgCompressionQuality
        self.asPdf = asPdf
    }

    static func fromArguments(args: Any?) -> CunningScannerOptions {
        guard let arguments = args as? [String: Any] else {
            return CunningScannerOptions()
        }

        let asPdf = (arguments["asPdf"] as? Bool) ?? false
        let scannerOptionsDict = arguments["iosScannerOptions"] as? [String: Any]
        let imageFormat = (scannerOptionsDict?["imageFormat"] as? String) ?? "png"
        let jpgCompressionQuality = (scannerOptionsDict?["jpgCompressionQuality"] as? Double) ?? 1.0

        return CunningScannerOptions(
            imageFormat: CunningScannerImageFormat(rawValue: imageFormat) ?? .png,
            jpgCompressionQuality: jpgCompressionQuality,
            asPdf: asPdf
        )
    }
}
