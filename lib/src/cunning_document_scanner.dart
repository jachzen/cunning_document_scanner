import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'exceptions.dart';
import 'ios_scanner_options.dart';

/// A class that provides a simple way to scan documents.
class CunningDocumentScanner {
  /// The method channel used to interact with the native platform.
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// Starts the document scanning process.
  ///
  /// This method will open the camera and allow the user to scan documents.
  ///
  /// [noOfPages] is the maximum number of pages that can be scanned.
  /// [isGalleryImportAllowed] is a flag that allows the user to import images from the gallery.
  /// [iosScannerOptions] is a set of options for the iOS scanner.
  ///
  /// Returns a list of paths to the scanned images, or null if the user cancels the operation.
  static Future<List<String>?> getPictures({
    int noOfPages = 100,
    bool isGalleryImportAllowed = false,
    IosScannerOptions? iosScannerOptions,
  }) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    if (statuses.containsValue(PermissionStatus.denied) ||
        statuses.containsValue(PermissionStatus.permanentlyDenied)) {
      throw const CunningDocumentScannerException.permissionDenied(
          'Camera permission not granted');
    }

    final List<dynamic>? pictures = await _channel.invokeMethod('getPictures', {
      'noOfPages': noOfPages,
      'isGalleryImportAllowed': isGalleryImportAllowed,
      if (iosScannerOptions != null)
        'iosScannerOptions': {
          'imageFormat': iosScannerOptions.imageFormat.name,
          'jpgCompressionQuality': iosScannerOptions.jpgCompressionQuality,
        }
    });
    return pictures?.map((e) => e as String).toList();
  }
}
