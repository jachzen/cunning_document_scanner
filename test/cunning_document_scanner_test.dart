import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'mocks/mock_permission_handler_platform.dart';

void main() {
  group('CunningDocumentScanner permission denied', () {
    setUp(() {
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform(permissionStatus: PermissionStatus.denied);
    });

    test('getPictures with denied permission', () async {
      expect(() async => await CunningDocumentScanner.getPictures(false), throwsA(isA<Exception>()));
    });
  });

  group('CunningDocumentScanner permission permanently denied', () {
    setUp(() {
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform(permissionStatus: PermissionStatus.permanentlyDenied);
    });

    test('getPictures with permanently denied permission', () async {
      expect(() async => await CunningDocumentScanner.getPictures(false), throwsA(isA<Exception>()));
    });
  });

  group('CunningDocumentScanner granted permission', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform();
    });

    test('getPictures with MissingPluginException', () async {
      expect(() async => await CunningDocumentScanner.getPictures(false), throwsA(isA<MissingPluginException>()));
    });
  });
}