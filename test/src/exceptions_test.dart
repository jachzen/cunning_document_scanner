import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CunningDocumentScannerException', () {
    test('creates exception with message and code', () {
      const exception = CunningDocumentScannerException(
        'Test error',
        code: 'test_code',
      );

      expect(exception.message, 'Test error');
      expect(exception.code, 'test_code');
    });

    test('creates exception with message only', () {
      const exception = CunningDocumentScannerException('Test error');

      expect(exception.message, 'Test error');
      expect(exception.code, isNull);
    });

    test('toString returns formatted error message with code', () {
      const exception = CunningDocumentScannerException(
        'Test error',
        code: 'test_code',
      );

      expect(
        exception.toString(),
        'CunningDocumentScannerException(test_code): Test error',
      );
    });

    test('toString returns formatted error message without code', () {
      const exception = CunningDocumentScannerException('Test error');

      expect(
        exception.toString(),
        'CunningDocumentScannerException(error): Test error',
      );
    });

    group('permissionDenied constructor', () {
      test('creates exception with default message', () {
        const exception = CunningDocumentScannerException.permissionDenied();

        expect(exception.message, 'Permission not granted');
        expect(exception.code, 'permission_denied');
      });

      test('creates exception with custom message', () {
        const exception = CunningDocumentScannerException.permissionDenied(
          'Camera permission denied',
        );

        expect(exception.message, 'Camera permission denied');
        expect(exception.code, 'permission_denied');
      });

      test('toString returns formatted permission error', () {
        const exception = CunningDocumentScannerException.permissionDenied(
          'Camera permission denied',
        );

        expect(
          exception.toString(),
          'CunningDocumentScannerException(permission_denied): Camera permission denied',
        );
      });
    });

    group('equality', () {
      test('two exceptions with same message and code are equal', () {
        const exception1 = CunningDocumentScannerException(
          'Test error',
          code: 'test_code',
        );
        const exception2 = CunningDocumentScannerException(
          'Test error',
          code: 'test_code',
        );

        expect(exception1, equals(exception2));
        expect(exception1.hashCode, equals(exception2.hashCode));
      });

      test('two exceptions with different messages are not equal', () {
        const exception1 = CunningDocumentScannerException(
          'Test error 1',
          code: 'test_code',
        );
        const exception2 = CunningDocumentScannerException(
          'Test error 2',
          code: 'test_code',
        );

        expect(exception1, isNot(equals(exception2)));
      });

      test('two exceptions with different codes are not equal', () {
        const exception1 = CunningDocumentScannerException(
          'Test error',
          code: 'code1',
        );
        const exception2 = CunningDocumentScannerException(
          'Test error',
          code: 'code2',
        );

        expect(exception1, isNot(equals(exception2)));
      });

      test('exception equals itself', () {
        const exception = CunningDocumentScannerException(
          'Test error',
          code: 'test_code',
        );

        expect(exception, equals(exception));
      });
    });

    group('implements Exception', () {
      test('can be caught as Exception', () {
        expect(
          () => throw const CunningDocumentScannerException('Test error'),
          throwsA(isA<Exception>()),
        );
      });

      test('can be caught as CunningDocumentScannerException', () {
        expect(
          () => throw const CunningDocumentScannerException('Test error'),
          throwsA(isA<CunningDocumentScannerException>()),
        );
      });
    });
  });
}
