import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import 'mocks/mock_permission_handler_platform.dart';

void main() {
  group('CunningDocumentScanner permission denied', () {
    setUp(() {
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform(
          permissionStatus: PermissionStatus.denied);
    });

    test('getPictures with denied permission', () async {
      expect(() async => await CunningDocumentScanner.getPictures(),
          throwsA(isA<Exception>()));
    });
  });

  group('CunningDocumentScanner permission permanently denied', () {
    setUp(() {
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform(
          permissionStatus: PermissionStatus.permanentlyDenied);
    });

    test('getPictures with permanently denied permission', () async {
      expect(() async => await CunningDocumentScanner.getPictures(),
          throwsA(isA<Exception>()));
    });
  });

  group('CunningDocumentScanner Plugin exceptions', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform();
    });

    test('getPictures with MissingPluginException', () async {
      expect(() async => await CunningDocumentScanner.getPictures(),
          throwsA(isA<MissingPluginException>()));
    });
  });

  group('CunningDocumentScanner granted permission', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      PermissionHandlerPlatform.instance = MockPermissionHandlerPlatform();
    });

    void loadPlatformChannel(WidgetTester tester, List<String> result) {
      MethodChannel channel = const MethodChannel('cunning_document_scanner');

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) => Future.value(result),
      );
    }

    testWidgets('getPictures empty result', (WidgetTester tester) async {
      final List<String> emptyResult = [];
      loadPlatformChannel(tester, emptyResult);
      final result = await CunningDocumentScanner.getPictures();
      expect(result, emptyResult);
    });

    testWidgets('getPictures multiple result', (WidgetTester tester) async {
      final List<String> fakeResult = ['fake_url1', 'fake_url2', 'fake_url3'];
      loadPlatformChannel(tester, fakeResult);
      final result = await CunningDocumentScanner.getPictures();
      expect(result, fakeResult);
    });
  });
}
