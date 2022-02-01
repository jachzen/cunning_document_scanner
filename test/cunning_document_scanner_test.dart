import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';

void main() {
  const MethodChannel channel = MethodChannel('cunning_document_scanner');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CunningDocumentScanner.platformVersion, '42');
  });
}
