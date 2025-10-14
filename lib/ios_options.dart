/// Enumerates the different output image formats are supported.
enum IosImageFormat {
  /// Indicates the output image should be formatted as JPEG image.
  jpg,

  /// Indicates the output image should be formatted as PNG image.
  png,
}

/// Different options that modify the behavior of the document scanner on iOS.
///
/// The [imageFormat] specifies the format of the output image file. Available
/// options are [IosImageFormat.jpeg] or [IosImageFormat.png]. Default value is
/// [IosImageFormat.png].
///
/// If [imageFormat] is set to [IosImageFormat.jpeg] the [jpgCompressionQuality]
/// can be used to control the quality of the resulting JPEG image. The value
/// 0.0 represents the maximum compression (or lowest quality) while the value
/// 1.0 represents the least compression (or best quality). Default value is 1.0.
final class IosScannerOptions {
  /// Creates a [IosScannerOptions].
  const IosScannerOptions({
    this.imageFormat = IosImageFormat.png,
    this.jpgCompressionQuality = 1.0,
  });

  final IosImageFormat imageFormat;

  /// The quality of the resulting JPEG image, expressed as a value from 0.0 to
  /// 1.0.
  ///
  /// The value 0.0 represents the maximum compression (or lowest quality) while
  /// the value 1.0 represents the least compression (or best quality). The
  /// [jpgCompressionQuality] only has an effect if the [imageFormat] is set to
  /// [IosImageFormat.jpeg] and is ignored otherwise.
  final double jpgCompressionQuality;
}
