import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pageable/flutter_pageable.dart';

void main() {
  group('FlutterPageableException', () {
    test('implements Exception', () {
      expect(FlutterPageableException('test'), isA<Exception>());
    });

    test('stores message', () {
      final exception = FlutterPageableException('Something went wrong');
      expect(exception.message, 'Something went wrong');
    });

    test('stores optional code', () {
      final exception = FlutterPageableException('Error', code: 404);
      expect(exception.code, 404);
    });

    test('code is null when not provided', () {
      final exception = FlutterPageableException('Error');
      expect(exception.code, isNull);
    });

    test('toString without code', () {
      final exception = FlutterPageableException('Something failed');
      expect(exception.toString(), 'Flutter Pageable Exception: Something failed');
    });

    test('toString with code', () {
      final exception = FlutterPageableException('Not found', code: 404);
      expect(exception.toString(), 'Flutter Pageable Exception: Not found. Code: 404');
    });

    test('message is mutable', () {
      final exception = FlutterPageableException('Original');
      exception.message = 'Updated';
      expect(exception.message, 'Updated');
    });

    test('code is mutable', () {
      final exception = FlutterPageableException('Error');
      exception.code = 500;
      expect(exception.code, 500);
    });
  });
}
