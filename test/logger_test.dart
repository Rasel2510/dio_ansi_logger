import 'package:dio_pretty_logger/dio_pretty_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggerThemes', () {
    test('dark theme has correct reset code', () {
      expect(LoggerThemes.dark.reset, equals('\x1B[0m'));
    });

    test('minimal theme has correct reset code', () {
      expect(LoggerThemes.minimal.reset, equals('\x1B[0m'));
    });

    test('solarized theme has correct reset code', () {
      expect(LoggerThemes.solarized.reset, equals('\x1B[0m'));
    });

    test('nord theme has correct reset code', () {
      expect(LoggerThemes.nord.reset, equals('\x1B[0m'));
    });
  });

  group('Ansi', () {
    test('reset code is correct', () {
      expect(Ansi.reset, equals('\x1B[0m'));
    });

    test('bold code is correct', () {
      expect(Ansi.bold, equals('\x1B[1m'));
    });

    test('brightGreen code is correct', () {
      expect(Ansi.brightGreen, equals('\x1B[92m'));
    });
  });

  group('DioLogger', () {
    test('can be instantiated with default theme', () {
      final logger = DioLogger();
      expect(logger.theme, equals(LoggerThemes.dark));
      expect(logger.logRequest, isTrue);
      expect(logger.logResponse, isTrue);
      expect(logger.logError, isTrue);
      expect(logger.maxBodyLength, equals(5000));
    });

    test('can be instantiated with custom theme', () {
      final logger = DioLogger(theme: LoggerThemes.minimal);
      expect(logger.theme, equals(LoggerThemes.minimal));
    });

    test('can disable request logging', () {
      final logger = DioLogger(logRequest: false);
      expect(logger.logRequest, isFalse);
    });

    test('respects maxBodyLength', () {
      final logger = DioLogger(maxBodyLength: 100);
      expect(logger.maxBodyLength, equals(100));
    });
  });
}
