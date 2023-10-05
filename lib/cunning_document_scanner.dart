import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CunningDocumentScanner {
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// Call this to start get Picture workflow.
  static Future<List<String>?> getPictures() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      throw Exception("Permission not granted");
    }

    final List<dynamic>? pictures = await _channel.invokeMethod('getPictures');
    return pictures?.map((e) => e as String).toList();
  }
}
