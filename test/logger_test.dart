import 'package:dio_ansi_logger/dio_ansi_logger.dart';
import 'package:test/test.dart';

void main() {
  // ─── LoggerThemes ────────────────────────────────────────────────────────────

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

    test('matrix theme has correct reset code', () {
      expect(LoggerThemes.matrix.reset, equals('\x1B[0m'));
    });

    test('all themes are distinct', () {
      final themes = [
        LoggerThemes.dark,
        LoggerThemes.minimal,
        LoggerThemes.solarized,
        LoggerThemes.nord,
        LoggerThemes.matrix,
      ];
      for (var i = 0; i < themes.length; i++) {
        for (var j = i + 1; j < themes.length; j++) {
          expect(themes[i], isNot(equals(themes[j])),
              reason: 'Theme $i and $j should be different');
        }
      }
    });
  });

  // ─── Ansi ────────────────────────────────────────────────────────────────────

  group('Ansi', () {
    test('reset code is correct', () {
      expect(Ansi.reset, equals('\x1B[0m'));
    });

    test('bold code is correct', () {
      expect(Ansi.bold, equals('\x1B[1m'));
    });

    test('dim code is correct', () {
      expect(Ansi.dim, equals('\x1B[2m'));
    });

    test('brightGreen code is correct', () {
      expect(Ansi.brightGreen, equals('\x1B[92m'));
    });

    test('brightRed code is correct', () {
      expect(Ansi.brightRed, equals('\x1B[91m'));
    });

    test('brightCyan code is correct', () {
      expect(Ansi.brightCyan, equals('\x1B[96m'));
    });
  });

  // ─── DioLogger ───────────────────────────────────────────────────────────────

  group('DioLogger', () {
    test('default theme is dark', () {
      final logger = DioLogger();
      expect(logger.theme, equals(LoggerThemes.dark));
    });

    test('default flags are all true', () {
      final logger = DioLogger();
      expect(logger.logRequest, isTrue);
      expect(logger.logResponse, isTrue);
      expect(logger.logError, isTrue);
    });

    test('default maxBodyLength is 5000', () {
      final logger = DioLogger();
      expect(logger.maxBodyLength, equals(5000));
    });

    test('can be instantiated with custom theme', () {
      const logger = DioLogger(theme: LoggerThemes.minimal);
      expect(logger.theme, equals(LoggerThemes.minimal));
    });

    test('can disable request logging', () {
      const logger = DioLogger(logRequest: false);
      expect(logger.logRequest, isFalse);
    });

    test('can disable response logging', () {
      const logger = DioLogger(logResponse: false);
      expect(logger.logResponse, isFalse);
    });

    test('can disable error logging', () {
      const logger = DioLogger(logError: false);
      expect(logger.logError, isFalse);
    });

    test('respects custom maxBodyLength', () {
      const logger = DioLogger(maxBodyLength: 100);
      expect(logger.maxBodyLength, equals(100));
    });

    test('two loggers with same theme config share equal theme', () {
      const a = DioLogger(theme: LoggerThemes.nord);
      const b = DioLogger(theme: LoggerThemes.nord);
      expect(a.theme, equals(b.theme));
    });
  });

  // ─── LoggerTheme equality ────────────────────────────────────────────────────

  group('LoggerTheme equality', () {
    test('same const instance is equal to itself', () {
      expect(LoggerThemes.dark, equals(LoggerThemes.dark));
    });

    test('dark and minimal themes are not equal', () {
      expect(LoggerThemes.dark, isNot(equals(LoggerThemes.minimal)));
    });

    test('two identical custom themes are equal', () {
      const t1 = LoggerTheme(
        sectionBorder: '\x1B[2m\x1B[36m',
        sectionTitle: '\x1B[1m\x1B[96m',
        label: '\x1B[2m\x1B[37m',
        value: '\x1B[97m',
        methodGet: '\x1B[1m\x1B[92m',
        methodPost: '\x1B[1m\x1B[94m',
        methodPut: '\x1B[1m\x1B[93m',
        methodDelete: '\x1B[1m\x1B[91m',
        methodPatch: '\x1B[1m\x1B[95m',
        statusSuccess: '\x1B[1m\x1B[92m',
        statusRedirect: '\x1B[1m\x1B[93m',
        statusError: '\x1B[1m\x1B[91m',
        jsonKey: '\x1B[96m',
        jsonString: '\x1B[92m',
        jsonNumber: '\x1B[93m',
        jsonBool: '\x1B[95m',
        jsonNull: '\x1B[2m\x1B[37m',
        errorTitle: '\x1B[1m\x1B[91m',
        errorValue: '\x1B[31m',
        dim: '\x1B[2m\x1B[37m',
        reset: '\x1B[0m',
      );
      const t2 = LoggerTheme(
        sectionBorder: '\x1B[2m\x1B[36m',
        sectionTitle: '\x1B[1m\x1B[96m',
        label: '\x1B[2m\x1B[37m',
        value: '\x1B[97m',
        methodGet: '\x1B[1m\x1B[92m',
        methodPost: '\x1B[1m\x1B[94m',
        methodPut: '\x1B[1m\x1B[93m',
        methodDelete: '\x1B[1m\x1B[91m',
        methodPatch: '\x1B[1m\x1B[95m',
        statusSuccess: '\x1B[1m\x1B[92m',
        statusRedirect: '\x1B[1m\x1B[93m',
        statusError: '\x1B[1m\x1B[91m',
        jsonKey: '\x1B[96m',
        jsonString: '\x1B[92m',
        jsonNumber: '\x1B[93m',
        jsonBool: '\x1B[95m',
        jsonNull: '\x1B[2m\x1B[37m',
        errorTitle: '\x1B[1m\x1B[91m',
        errorValue: '\x1B[31m',
        dim: '\x1B[2m\x1B[37m',
        reset: '\x1B[0m',
      );
      expect(t1, equals(t2));
    });
  });
}
