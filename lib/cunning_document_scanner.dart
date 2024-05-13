import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class AndroidScannerOptions {
  const AndroidScannerOptions({
    this.isGalleryImportAllowed = false,
    this.scannerMode = AndroidScannerMode.scannerModeFull,
    this.noOfPages = 100,
  });

  final bool isGalleryImportAllowed;
  final AndroidScannerMode scannerMode;
  final int noOfPages;
}

enum AndroidScannerMode {
  scannerModeFull(
      1), // adds ML-enabled image cleaning capabilities (erase stains, fingers, etc…) to the SCANNER_MODE_BASE_WITH_FILTER mode.
  scannerModeBaseWithFilter(
      2), // Adds image filters (grayscale, auto image enhancement, etc…) to the SCANNER_MODE_BASE mode.
  scannerModeBase(
      3); // basic editing capabilities (crop, rotate, reorder pages, etc…).

  const AndroidScannerMode(this.value);
  final int value;
}

class IOSScannerOptions {
  const IOSScannerOptions({
    this.isGalleryImportAllowed = false,
    this.isAutoScanAllowed = true,
    this.isAutoScanEnabled = true,
    this.isFlashAllowed = true,
    this.backgroundColor = Colors.white,
    this.tintColor = Colors.blue,
  });

  final bool isGalleryImportAllowed;
  final bool isAutoScanAllowed;
  final bool isAutoScanEnabled;
  final bool isFlashAllowed;

  final Color backgroundColor;
  final Color tintColor;
}

class CunningDocumentScanner {
  static const _defaultAndroidOptions = AndroidScannerOptions();
  static const _defaultIOSOptions = IOSScannerOptions();

  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// Call this to start get Picture workflow.
  static Future<List<String>?> getPictures({
    AndroidScannerOptions androidOptions = _defaultAndroidOptions,
    IOSScannerOptions iOSOptions = _defaultIOSOptions,
  }) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    if (statuses.containsValue(PermissionStatus.denied) ||
        statuses.containsValue(PermissionStatus.permanentlyDenied)) {
      throw Exception("Permission not granted");
    }

    List<dynamic>? pictures;
    if (Platform.isAndroid) {
      pictures = await _channel.invokeMethod('getPictures', {
        'noOfPages': androidOptions.noOfPages,
        'isGalleryImportAllowed': androidOptions.isGalleryImportAllowed,
        'scannerMode': androidOptions.scannerMode.value,
      });
    } else if (Platform.isIOS) {
      pictures = await _channel.invokeMethod('getPictures', {
        'isGalleryImportAllowed': iOSOptions.isGalleryImportAllowed,
        'isAutoScanAllowed': iOSOptions.isAutoScanAllowed,
        'isAutoScanEnabled': iOSOptions.isAutoScanEnabled,
        'isFlashAllowed': iOSOptions.isFlashAllowed,
        'backgroundColor': iOSOptions.backgroundColor.value,
        'tintColor': iOSOptions.tintColor.value,
      });
    }
    return pictures?.map((e) => e as String).toList();
  }
}
