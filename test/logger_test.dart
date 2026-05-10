import 'package:test/test.dart';
import 'package:dio/dio.dart';
import 'package:dio_ansi_logger/dio_ansi_logger.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// Runs [logger.onRequest] synchronously and returns the log output.
/// Returns null if nothing was logged (e.g. filtered or disabled).
String? captureRequest(DioLogger logger, RequestOptions options) {
  String? output;
  final capturing = DioLogger(
    theme: logger.theme,
    logRequest: logger.logRequest,
    logResponse: logger.logResponse,
    logError: logger.logError,
    logRequestHeaders: logger.logRequestHeaders,
    logRequestBody: logger.logRequestBody,
    logResponseHeaders: logger.logResponseHeaders,
    logResponseBody: logger.logResponseBody,
    maxBodyLength: logger.maxBodyLength,
    logResponseTime: false,
    redactedHeaders: logger.redactedHeaders,
    redactedPlaceholder: logger.redactedPlaceholder,
    requestFilter: logger.requestFilter,
    logPrint: (msg) => output = msg,
  );
  capturing.onRequest(options, RequestInterceptorHandler());
  return output;
}

/// Runs [logger.onResponse] synchronously and returns the log output.
String? captureResponse(DioLogger logger, Response<dynamic> response) {
  String? output;
  final capturing = DioLogger(
    theme: logger.theme,
    logRequest: logger.logRequest,
    logResponse: logger.logResponse,
    logError: logger.logError,
    logRequestHeaders: logger.logRequestHeaders,
    logRequestBody: logger.logRequestBody,
    logResponseHeaders: logger.logResponseHeaders,
    logResponseBody: logger.logResponseBody,
    maxBodyLength: logger.maxBodyLength,
    logResponseTime: false,
    redactedHeaders: logger.redactedHeaders,
    redactedPlaceholder: logger.redactedPlaceholder,
    responseFilter: logger.responseFilter,
    logPrint: (msg) => output = msg,
  );
  capturing.onResponse(response, ResponseInterceptorHandler());
  return output;
}

/// Runs [logger.onError] synchronously and returns the log output.
String? captureError(DioLogger logger, DioException err) {
  String? output;
  final capturing = DioLogger(
    theme: logger.theme,
    logRequest: logger.logRequest,
    logResponse: logger.logResponse,
    logError: logger.logError,
    logRequestHeaders: logger.logRequestHeaders,
    logRequestBody: logger.logRequestBody,
    logResponseHeaders: logger.logResponseHeaders,
    logResponseBody: logger.logResponseBody,
    maxBodyLength: logger.maxBodyLength,
    logResponseTime: false,
    redactedHeaders: logger.redactedHeaders,
    redactedPlaceholder: logger.redactedPlaceholder,
    errorFilter: logger.errorFilter,
    logPrint: (msg) => output = msg,
  );
  capturing.onError(err, ErrorInterceptorHandler());
  return output;
}

RequestOptions _opts({
  String path = '/test',
  String method = 'GET',
  Map<String, dynamic>? headers,
  dynamic data,
  Map<String, dynamic>? queryParameters,
}) =>
    RequestOptions(
      path: path,
      method: method,
      headers: headers ?? {},
      data: data,
      queryParameters: queryParameters ?? {},
    );

Response<dynamic> _response({
  dynamic data,
  int statusCode = 200,
  String statusMessage = 'OK',
  RequestOptions? requestOptions,
}) =>
    Response<dynamic>(
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      requestOptions: requestOptions ?? _opts(),
    );

DioException _dioError({
  DioExceptionType type = DioExceptionType.unknown,
  String? message,
  Response<dynamic>? response,
  RequestOptions? requestOptions,
}) =>
    DioException(
      type: type,
      message: message,
      response: response,
      requestOptions: requestOptions ?? _opts(),
    );

// ─── Tests ────────────────────────────────────────────────────────────────────

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

    test('italic code is correct', () {
      expect(Ansi.italic, equals('\x1B[3m'));
    });

    test('underline code is correct', () {
      expect(Ansi.underline, equals('\x1B[4m'));
    });

    test('strikethrough code is correct', () {
      expect(Ansi.strikethrough, equals('\x1B[9m'));
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

    test('bgRed code is correct', () {
      expect(Ansi.bgRed, equals('\x1B[41m'));
    });

    test('bgGreen code is correct', () {
      expect(Ansi.bgGreen, equals('\x1B[42m'));
    });
  });

  // ─── DioLogger — defaults ────────────────────────────────────────────────────

  group('DioLogger defaults', () {
    test('default theme is dark', () {
      expect(const DioLogger().theme, equals(LoggerThemes.dark));
    });

    test('logRequest / logResponse / logError default to true', () {
      const l = DioLogger();
      expect(l.logRequest, isTrue);
      expect(l.logResponse, isTrue);
      expect(l.logError, isTrue);
    });

    test('logRequestHeaders and logRequestBody default to true', () {
      const l = DioLogger();
      expect(l.logRequestHeaders, isTrue);
      expect(l.logRequestBody, isTrue);
    });

    test('logResponseHeaders defaults to false, logResponseBody to true', () {
      const l = DioLogger();
      expect(l.logResponseHeaders, isFalse);
      expect(l.logResponseBody, isTrue);
    });

    test('maxBodyLength defaults to 5000', () {
      expect(const DioLogger().maxBodyLength, equals(5000));
    });

    test('logResponseTime defaults to true', () {
      expect(const DioLogger().logResponseTime, isTrue);
    });

    test('redactedHeaders contains the four default keys', () {
      final headers = const DioLogger().redactedHeaders;
      expect(headers,
          containsAll(['authorization', 'x-api-key', 'cookie', 'set-cookie']));
    });

    test('redactedPlaceholder defaults to [REDACTED]', () {
      expect(const DioLogger().redactedPlaceholder, equals('[REDACTED]'));
    });

    test('logPrint defaults to null', () {
      expect(const DioLogger().logPrint, isNull);
    });

    test('filters default to null', () {
      const l = DioLogger();
      expect(l.requestFilter, isNull);
      expect(l.responseFilter, isNull);
      expect(l.errorFilter, isNull);
    });

    test('can be instantiated with custom theme', () {
      const l = DioLogger(theme: LoggerThemes.minimal);
      expect(l.theme, equals(LoggerThemes.minimal));
    });

    test('two loggers with same theme share equal theme', () {
      const a = DioLogger(theme: LoggerThemes.nord);
      const b = DioLogger(theme: LoggerThemes.nord);
      expect(a.theme, equals(b.theme));
    });
  });

  // ─── logPrint ─────────────────────────────────────────────────────────────────

  group('logPrint callback', () {
    test('request output goes through logPrint', () {
      final logs = <String>[];
      final logger = DioLogger(logPrint: logs.add);
      try {
        logger.onRequest(_opts(), RequestInterceptorHandler());
      } catch (_) {}
      expect(logs, hasLength(1));
      expect(logs.first, contains('REQUEST'));
    });

    test('response output goes through logPrint', () {
      final logs = <String>[];
      final logger = DioLogger(logPrint: logs.add, logResponseTime: false);
      try {
        logger.onResponse(_response(), ResponseInterceptorHandler());
      } catch (_) {}
      expect(logs, hasLength(1));
      expect(logs.first, contains('RESPONSE'));
    });

    test('no output when logRequest is false', () {
      final logs = <String>[];
      final logger = DioLogger(logRequest: false, logPrint: logs.add);
      try {
        logger.onRequest(_opts(), RequestInterceptorHandler());
      } catch (_) {}
      expect(logs, isEmpty);
    });

    test('no output when logResponse is false', () {
      final logs = <String>[];
      final logger = DioLogger(
          logResponse: false, logPrint: logs.add, logResponseTime: false);
      try {
        logger.onResponse(_response(), ResponseInterceptorHandler());
      } catch (_) {}
      expect(logs, isEmpty);
    });
  });

  // ─── Request logging ─────────────────────────────────────────────────────────

  group('Request logging', () {
    test('logs method and URL', () {
      final output = captureRequest(
          const DioLogger(), _opts(path: '/users', method: 'GET'));
      expect(output, isNotNull);
      expect(output, contains('GET'));
      expect(output, contains('/users'));
    });

    test('logs query parameters when present', () {
      final output = captureRequest(
        const DioLogger(),
        _opts(queryParameters: {'page': '1', 'limit': '20'}),
      );
      expect(output, contains('Query'));
      expect(output, contains('page'));
    });

    test('does not log query section when empty', () {
      final output = captureRequest(const DioLogger(), _opts());
      expect(output, isNot(contains('Query')));
    });

    test('logs headers when logRequestHeaders is true', () {
      final output = captureRequest(
        const DioLogger(logRequestHeaders: true),
        _opts(headers: {'content-type': 'application/json'}),
      );
      expect(output, contains('Headers'));
      expect(output, contains('content-type'));
    });

    test('does not log headers when logRequestHeaders is false', () {
      final output = captureRequest(
        const DioLogger(logRequestHeaders: false),
        _opts(headers: {'content-type': 'application/json'}),
      );
      expect(output, isNot(contains('content-type')));
    });

    test('logs body when logRequestBody is true', () {
      final output = captureRequest(
        const DioLogger(logRequestBody: true),
        _opts(data: {'name': 'Alice'}),
      );
      expect(output, contains('Body'));
      expect(output, contains('name'));
    });

    test('does not log body when logRequestBody is false', () {
      final output = captureRequest(
        const DioLogger(logRequestBody: false),
        _opts(data: {'name': 'Alice'}),
      );
      expect(output, isNot(contains('name')));
    });
  });

  // ─── Header redaction ────────────────────────────────────────────────────────

  group('Header redaction', () {
    test('redacts authorization header', () {
      final output = captureRequest(
        const DioLogger(),
        _opts(headers: {'authorization': 'Bearer super-secret-token'}),
      );
      expect(output, contains('[REDACTED]'));
      expect(output, isNot(contains('super-secret-token')));
    });

    test('redaction is case-insensitive', () {
      final output = captureRequest(
        const DioLogger(),
        _opts(headers: {'Authorization': 'Bearer secret'}),
      );
      expect(output, contains('[REDACTED]'));
      expect(output, isNot(contains('Bearer secret')));
    });

    test('non-sensitive headers are not redacted', () {
      final output = captureRequest(
        const DioLogger(),
        _opts(headers: {'content-type': 'application/json'}),
      );
      expect(output, contains('application/json'));
    });

    test('custom redactedHeaders are respected', () {
      final output = captureRequest(
        const DioLogger(redactedHeaders: {'x-custom-secret'}),
        _opts(headers: {
          'x-custom-secret': 'my-secret',
          'authorization': 'Bearer visible', // not in custom set
        }),
      );
      expect(output, isNot(contains('my-secret')));
      expect(output, contains('Bearer visible')); // authorization not redacted
    });

    test('custom redactedPlaceholder is used', () {
      final output = captureRequest(
        const DioLogger(redactedPlaceholder: '***'),
        _opts(headers: {'authorization': 'secret'}),
      );
      expect(output, contains('***'));
      expect(output, isNot(contains('[REDACTED]')));
    });
  });

  // ─── Body truncation ─────────────────────────────────────────────────────────

  group('Body truncation', () {
    test('truncates body at maxBodyLength', () {
      final longString = 'x' * 200;
      final output = captureRequest(
        const DioLogger(maxBodyLength: 50),
        _opts(data: longString),
      );
      expect(output, contains('[truncated'));
    });

    test('does not truncate body under maxBodyLength', () {
      final output = captureRequest(
        const DioLogger(maxBodyLength: 5000),
        _opts(data: {'key': 'short'}),
      );
      expect(output, isNot(contains('[truncated')));
    });

    test('does not crash when truncation cuts mid-line in large JSON response',
        () {
      // Reproduces the RangeError from substring(colonIndex + 2) when
      // maxBodyLength slices the body at a point like `"someKey":` with no
      // value following — e.g. a response with many sections like id=100.
      final largeData = {
        for (var i = 0; i < 30; i++)
          'sectionKey_$i': {
            'title': 'Section $i title text',
            'description': 'Some longer description for section number $i',
            'active': true,
            'count': i * 10,
          }
      };
      for (var cutAt = 40; cutAt <= 120; cutAt += 7) {
        expect(
          () => captureResponse(
            DioLogger(maxBodyLength: cutAt),
            _response(data: largeData),
          ),
          returnsNormally,
          reason: 'Should not throw at maxBodyLength=$cutAt',
        );
      }
    });
  });

  // ─── JSON colorizer ───────────────────────────────────────────────────────────

  group('JSON colorizer / body formatting', () {
    test('handles URLs as values without misparse', () {
      final output = captureResponse(
        const DioLogger(),
        _response(data: {'url': 'https://api.example.com/v1/users?page=1'}),
      );
      expect(output, contains('https://api.example.com/v1/users?page=1'));
    });

    test('handles null body gracefully', () {
      final output = captureResponse(const DioLogger(), _response(data: null));
      expect(output, contains('(empty)'));
    });

    test('handles plain string body', () {
      final output = captureResponse(
          const DioLogger(), _response(data: 'plain text response'));
      expect(output, contains('plain text response'));
    });

    test('handles nested JSON', () {
      final output = captureResponse(
        const DioLogger(),
        _response(data: {
          'user': {'id': 1, 'name': 'Alice'},
          'active': true,
        }),
      );
      expect(output, contains('user'));
      expect(output, contains('Alice'));
      expect(output, contains('true'));
    });

    test('handles JSON array', () {
      final output = captureResponse(
        const DioLogger(),
        _response(data: [1, 2, 3]),
      );
      expect(output, isNotNull);
    });

    test('handles scientific notation numbers', () {
      final output = captureResponse(
        const DioLogger(),
        _response(data: {'value': 1.5e10}),
      );
      expect(output, isNotNull);
    });
  });

  // ─── Response logging ────────────────────────────────────────────────────────

  group('Response logging', () {
    test('logs status code', () {
      final output =
          captureResponse(const DioLogger(), _response(statusCode: 201));
      expect(output, contains('201'));
    });

    test('logs method', () {
      final output = captureResponse(
        const DioLogger(),
        _response(requestOptions: _opts(method: 'POST')),
      );
      expect(output, contains('POST'));
    });

    test('does not log response body when logResponseBody is false', () {
      final output = captureResponse(
        const DioLogger(logResponseBody: false),
        _response(data: {'secret': 'data'}),
      );
      expect(output, isNot(contains('secret')));
    });

    test('does not show response headers by default', () {
      final output = captureResponse(const DioLogger(), _response());
      expect(output, isNot(contains('Headers')));
    });
  });

  // ─── Error logging ────────────────────────────────────────────────────────────

  group('Error logging', () {
    test('logs error type', () {
      final output = captureError(
        const DioLogger(),
        _dioError(type: DioExceptionType.connectionTimeout),
      );
      expect(output, contains('connectionTimeout'));
    });

    test('logs error message when present', () {
      final output = captureError(
        const DioLogger(),
        _dioError(message: 'Connection refused'),
      );
      expect(output, contains('Connection refused'));
    });

    test('logs error response status when present', () {
      final output = captureError(
        const DioLogger(),
        _dioError(
          response: _response(statusCode: 404, statusMessage: 'Not Found'),
        ),
      );
      expect(output, contains('404'));
    });

    test('logs error response body when present', () {
      final output = captureError(
        const DioLogger(),
        _dioError(
          response: _response(data: {'error': 'not_found'}),
        ),
      );
      expect(output, contains('not_found'));
    });

    test('no output when logError is false', () {
      final output = captureError(
        const DioLogger(logError: false),
        _dioError(),
      );
      expect(output, isNull);
    });
  });

  // ─── Filters ─────────────────────────────────────────────────────────────────

  group('Filters', () {
    test('requestFilter returning false suppresses log', () {
      final output = captureRequest(
        DioLogger(requestFilter: (_) => false),
        _opts(path: '/health'),
      );
      expect(output, isNull);
    });

    test('requestFilter returning true allows log', () {
      final output = captureRequest(
        DioLogger(requestFilter: (o) => o.path.contains('/api')),
        _opts(path: '/api/users'),
      );
      expect(output, isNotNull);
    });

    test('requestFilter can filter by path', () {
      String? logged;
      final logger = DioLogger(
        requestFilter: (o) => !o.path.contains('/health'),
        logPrint: (msg) => logged = msg,
        logResponseTime: false,
      );
      try {
        logger.onRequest(_opts(path: '/health'), RequestInterceptorHandler());
      } catch (_) {}
      expect(logged, isNull);

      try {
        logger.onRequest(
            _opts(path: '/api/users'), RequestInterceptorHandler());
      } catch (_) {}
      expect(logged, isNotNull);
    });

    test('responseFilter returning false suppresses log', () {
      final output = captureResponse(
        DioLogger(responseFilter: (r) => r.statusCode != 304),
        _response(statusCode: 304),
      );
      expect(output, isNull);
    });

    test('errorFilter returning false suppresses log', () {
      final output = captureError(
        DioLogger(errorFilter: (e) => e.response?.statusCode != 401),
        _dioError(response: _response(statusCode: 401)),
      );
      expect(output, isNull);
    });

    test('errorFilter returning true allows log', () {
      final output = captureError(
        DioLogger(errorFilter: (e) => e.response?.statusCode != 401),
        _dioError(response: _response(statusCode: 500)),
      );
      expect(output, isNotNull);
    });
  });

  // ─── HTTP method colors ───────────────────────────────────────────────────────

  group('HTTP method display', () {
    for (final method in [
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'HEAD',
      'OPTIONS'
    ]) {
      test('$method appears in request log', () {
        final output = captureRequest(const DioLogger(), _opts(method: method));
        expect(output, contains(method));
      });
    }
  });

  // ─── LoggerTheme equality ────────────────────────────────────────────────────

  group('LoggerTheme equality', () {
    test('same const instance is equal to itself', () {
      expect(LoggerThemes.dark, equals(LoggerThemes.dark));
    });

    test('dark and minimal are not equal', () {
      expect(LoggerThemes.dark, isNot(equals(LoggerThemes.minimal)));
    });

    test('two identical custom themes are equal', () {
      const t1 = LoggerTheme(
        sectionBorder: '\x1B[2m\x1B[36m',
        sectionTitle: '\x1B[1m\x1B[96m',
        label: '\x1B[2m\x1B[37m',
        value: '\x1B[97m',
        underline: '\x1B[4m',
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
        underline: '\x1B[4m',
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

  // ─── LoggerTheme.copyWith ────────────────────────────────────────────────────

  group('LoggerTheme.copyWith', () {
    test('copyWith returns equal theme when no fields changed', () {
      final copy = LoggerThemes.dark.copyWith();
      expect(copy, equals(LoggerThemes.dark));
    });

    test('copyWith changes only the specified field', () {
      final copy = LoggerThemes.dark
          .copyWith(errorTitle: Ansi.bold + Ansi.brightMagenta);
      expect(copy.errorTitle, equals(Ansi.bold + Ansi.brightMagenta));
      expect(copy.sectionBorder, equals(LoggerThemes.dark.sectionBorder));
      expect(copy.jsonKey, equals(LoggerThemes.dark.jsonKey));
    });

    test('copyWith result is not equal to original when field differs', () {
      final copy = LoggerThemes.dark.copyWith(jsonKey: Ansi.yellow);
      expect(copy, isNot(equals(LoggerThemes.dark)));
    });

    test('copyWith can override multiple fields', () {
      final copy = LoggerThemes.dark.copyWith(
        jsonKey: Ansi.yellow,
        jsonString: Ansi.green,
        dim: Ansi.dim + Ansi.cyan,
      );
      expect(copy.jsonKey, equals(Ansi.yellow));
      expect(copy.jsonString, equals(Ansi.green));
      expect(copy.dim, equals(Ansi.dim + Ansi.cyan));
      expect(copy.reset, equals(LoggerThemes.dark.reset));
    });
  });
}
