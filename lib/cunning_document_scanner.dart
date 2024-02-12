import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class CunningDocumentScanner {
  static const MethodChannel _channel =
      MethodChannel('cunning_document_scanner');

  /// Call this to start get Picture workflow.
  static Future<List<String>?> getPictures([bool crop = false, int noOfPages = 100, int imageQuality = 100]) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
    ].request();
    if (statuses.containsValue(PermissionStatus.denied) ||
        statuses.containsValue(PermissionStatus.permanentlyDenied)) {
      throw Exception("Permission not granted");
    }

    final List<dynamic>? pictures =
        await _channel.invokeMethod('getPictures', {'crop': crop, 'noOfPages': noOfPages, 'imageQuality': imageQuality});
    return pictures?.map((e) => e as String).toList();
  }
}
