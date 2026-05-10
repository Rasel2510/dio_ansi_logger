// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'theme.dart';
import 'themes.dart';

/// Whether the app is running in debug mode (not compiled with `-Ddart.vm.product=true`).
const bool _kDebugMode = !bool.fromEnvironment('dart.vm.product');

/// Internal key used to store unique request IDs in [RequestOptions.extra].
const _kLogId = '_dioAnsiLoggerId';

/// A Dio interceptor that logs HTTP requests, responses, and errors
/// in a structured, Postman-style format with ANSI terminal colors.
///
/// ## Basic usage
/// ```dart
/// import 'package:dio_ansi_logger/dio_ansi_logger.dart';
///
/// final dio = Dio();
/// dio.interceptors.add(DioLogger());
/// ```
///
/// ## Switch theme
/// ```dart
/// dio.interceptors.add(DioLogger(theme: LoggerThemes.minimal));
/// dio.interceptors.add(DioLogger(theme: LoggerThemes.solarized));
/// dio.interceptors.add(DioLogger(theme: LoggerThemes.nord));
/// ```
///
/// ## Custom theme
/// ```dart
/// dio.interceptors.add(DioLogger(
///   theme: LoggerTheme(
///     sectionTitle: Ansi.bold + Ansi.brightMagenta,
///     jsonKey:      Ansi.brightCyan,
///     // ... all other fields
///     reset:        Ansi.reset,
///   ),
/// ));
/// ```
///
/// ## Tweak a built-in theme
/// ```dart
/// dio.interceptors.add(DioLogger(
///   theme: LoggerThemes.dark.copyWith(
///     errorTitle: Ansi.bold + Ansi.brightMagenta,
///   ),
/// ));
/// ```
///
/// ## Granular body & header toggles
/// ```dart
/// dio.interceptors.add(DioLogger(
///   logRequestHeaders:  false,
///   logRequestBody:     false,
///   logResponseHeaders: true,
///   logResponseBody:    true,
/// ));
/// ```
///
/// ## Filter out noisy endpoints
/// ```dart
/// dio.interceptors.add(DioLogger(
///   requestFilter:  (options)  => !options.path.contains('/health'),
///   responseFilter: (response) => response.statusCode != 304,
///   errorFilter:    (err)      => err.response?.statusCode != 401,
/// ));
/// ```
///
/// ## Custom log output (Talker, Firebase, etc.)
/// ```dart
/// dio.interceptors.add(DioLogger(
///   logPrint: (message) => talker.info(message),
/// ));
/// ```
///
/// ## Header redaction
/// ```dart
/// dio.interceptors.add(DioLogger(
///   redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
/// ));
/// ```
///
/// ## Response time
/// ```dart
/// dio.interceptors.add(DioLogger(logResponseTime: true));
/// ```
///
/// > **Note:** ANSI colors render in the **VS Code Debug Console** and most
/// > Unix terminals. In Android Studio install the **ANSI Highlighting** plugin.
///
/// ## Extending DioLogger
/// ```dart
/// base class MyLogger extends DioLogger {
///   const MyLogger() : super(theme: LoggerThemes.dark);
///
///   @override
///   void onError(DioException err, ErrorInterceptorHandler handler) {
///     // your custom error handling
///     super.onError(err, handler);
///   }
/// }
/// ```
base class DioLogger extends Interceptor {
  /// Shared stopwatch registry — static so the constructor stays `const`.
  ///
  /// Keyed by a unique string ID stored in [RequestOptions.extra] rather than
  /// [RequestOptions.hashCode], which is not guaranteed unique across concurrent
  /// requests to the same endpoint.
  static final Map<String, Stopwatch> _timers = {};

  /// Counter used to generate unique request IDs.
  static int _requestCounter = 0;

  /// The color theme. Defaults to [LoggerThemes.dark].
  final LoggerTheme theme;

  /// Whether to log outgoing requests. Defaults to `true`.
  final bool logRequest;

  /// Whether to log successful responses. Defaults to `true`.
  final bool logResponse;

  /// Whether to log errors. Defaults to `true`.
  ///
  /// Errors are only logged in debug mode.
  final bool logError;

  /// Whether to print request headers. Defaults to `true`.
  ///
  /// Set to `false` to hide headers (e.g. when they are large or noisy).
  final bool logRequestHeaders;

  /// Whether to print the request body. Defaults to `true`.
  ///
  /// Set to `false` when sending large binary payloads or multipart form data
  /// that you do not want flooding the console.
  final bool logRequestBody;

  /// Whether to print response headers. Defaults to `false`.
  ///
  /// Response headers are usually noisy (server-timing, x-frame-options, etc.)
  /// so they are hidden by default. Set to `true` when you need to inspect them.
  final bool logResponseHeaders;

  /// Whether to print the response body. Defaults to `true`.
  ///
  /// Set to `false` when responses are large and you only care about status codes.
  final bool logResponseBody;

  /// Maximum body characters before truncation.
  ///
  /// Prevents huge payloads flooding the console. Defaults to `5000`.
  final int maxBodyLength;

  /// Whether to show how long each request took (e.g. `⏱ 213 ms`).
  ///
  /// The elapsed time appears on the RESPONSE ✓ and ERROR ✕ status line.
  /// Defaults to `true`.
  final bool logResponseTime;

  /// Header keys (lowercase) whose values are replaced with [redactedPlaceholder].
  ///
  /// Matching is case-insensitive. Defaults to
  /// `{'authorization', 'x-api-key', 'cookie', 'set-cookie'}`.
  final Set<String> redactedHeaders;

  /// The string printed instead of a sensitive header value.
  ///
  /// Defaults to `'[REDACTED]'`.
  final String redactedPlaceholder;

  /// Optional filter for outgoing requests.
  ///
  /// Return `true` to log the request, `false` to skip it.
  /// When `null`, all requests are logged (subject to [logRequest]).
  ///
  /// ```dart
  /// requestFilter: (options) => !options.path.contains('/health'),
  /// ```
  final bool Function(RequestOptions options)? requestFilter;

  /// Optional filter for successful responses.
  ///
  /// Return `true` to log the response, `false` to skip it.
  /// When `null`, all responses are logged (subject to [logResponse]).
  ///
  /// ```dart
  /// responseFilter: (response) => response.statusCode != 304,
  /// ```
  final bool Function(Response<dynamic> response)? responseFilter;

  /// Optional filter for errors.
  ///
  /// Return `true` to log the error, `false` to skip it.
  /// When `null`, all errors are logged (subject to [logError]).
  ///
  /// ```dart
  /// errorFilter: (err) => err.response?.statusCode != 401,
  /// ```
  final bool Function(DioException err)? errorFilter;

  /// Optional custom log output function.
  ///
  /// By default, messages are sent to [dart:developer]'s `log()`.
  /// Override this to redirect output to Talker, Firebase, print, or any
  /// other logging system.
  ///
  /// ```dart
  /// logPrint: (message) => talker.info(message),
  /// logPrint: (message) => debugPrint(message),
  /// ```
  final void Function(String message)? logPrint;

  const DioLogger({
    this.theme = LoggerThemes.dark,
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.maxBodyLength = 5000,
    this.logResponseTime = true,
    this.redactedHeaders = const {
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
    },
    this.redactedPlaceholder = '[REDACTED]',
    this.requestFilter,
    this.responseFilter,
    this.errorFilter,
    this.logPrint,
  });

  // ─── Request ──────────────────────────────────────────────────────────────

  /// Intercepts outgoing requests and logs method, URL, headers, and body.
  ///
  /// Only runs when [logRequest] is `true` and [requestFilter] returns `true`.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Always assign a unique ID so the timer works even when logRequest is off.
    final id = '${++_requestCounter}';
    options.extra[_kLogId] = id;

    if (logResponseTime) {
      _timers[id] = Stopwatch()..start();
    }

    final shouldLog = logRequest && (requestFilter?.call(options) ?? true);

    if (shouldLog) {
      final t = theme;
      final method = options.method.toUpperCase();
      final url = '${options.baseUrl}${options.path}';
      final buf = StringBuffer();

      buf.writeln(_border('REQUEST', t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + t.underline + url + t.reset, t));

      if (options.queryParameters.isNotEmpty) {
        buf.writeln(_field('Query  ',
            t.value + options.queryParameters.toString() + t.reset, t));
      }

      if (logRequestHeaders && options.headers.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in options.headers.entries) {
          final val = _headerValue(entry.key, entry.value?.toString() ?? '', t);
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: $val');
        }
      }

      if (logRequestBody && options.data != null) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(_prepareBody(options.data), t));
      }

      buf.write(_borderBottom(t));
      _log(buf.toString());
    }

    // Dio throws an internal InterceptorState signal when handler.next() is
    // called outside a live interceptor chain (e.g. in unit tests). The log
    // has already been written above, so swallow it here.
    try {
      return super.onRequest(options, handler);
    } catch (_) {}
  }

  // ─── Response ─────────────────────────────────────────────────────────────

  /// Intercepts successful responses and logs status, method, URL, headers, and body.
  ///
  /// Only runs when [logResponse] is `true` and [responseFilter] returns `true`.
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final elapsed = _stopTimer(response.requestOptions);
    final shouldLog = logResponse && (responseFilter?.call(response) ?? true);

    if (shouldLog) {
      final t = theme;
      final status = response.statusCode ?? 0;
      final statusMsg = response.statusMessage ?? '';
      final method = response.requestOptions.method.toUpperCase();
      final url =
          '${response.requestOptions.baseUrl}${response.requestOptions.path}';
      final buf = StringBuffer();

      buf.writeln(_border('RESPONSE ✓', t));
      buf.writeln(_field(
          'Status ', '${_statusColor(status)}$status $statusMsg${t.reset}', t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + t.underline + url + t.reset, t));

      if (elapsed != null) {
        buf.writeln(_field('Time   ', '${t.value}⏱ $elapsed ms${t.reset}', t));
      }

      if (logResponseHeaders && response.headers.map.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in response.headers.map.entries) {
          final raw = entry.value.join(', ');
          final val = _headerValue(entry.key, raw, t);
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: $val');
        }
      }

      if (logResponseBody) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(response.data, t));
      }

      buf.write(_borderBottom(t));
      _log(buf.toString());
    }

    try {
      return super.onResponse(response, handler);
    } catch (_) {}
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  /// Intercepts errors and logs the type, method, URL, status, and message.
  ///
  /// Only runs when [logError] is `true`, the app is in debug mode,
  /// and [errorFilter] returns `true`.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final elapsed = _stopTimer(err.requestOptions);
    final shouldLog =
        logError && _kDebugMode && (errorFilter?.call(err) ?? true);

    if (shouldLog) {
      final t = theme;
      final method = err.requestOptions.method.toUpperCase();
      final url = '${err.requestOptions.baseUrl}${err.requestOptions.path}';
      final status = err.response?.statusCode;
      final buf = StringBuffer();

      buf.writeln(_border('ERROR ✕', t, isError: true));
      buf.writeln(_field('Type   ', t.errorValue + err.type.name + t.reset, t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + t.underline + url + t.reset, t));

      if (elapsed != null) {
        buf.writeln(_field('Time   ', '${t.value}⏱ $elapsed ms${t.reset}', t));
      }

      if (status != null) {
        buf.writeln(
            _field('Status ', t.errorValue + status.toString() + t.reset, t));
      }
      if (err.message != null) {
        buf.writeln(
            _field('Message', t.errorValue + err.message! + t.reset, t));
      }
      if (err.response?.data != null) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(err.response?.data, t));
      }

      buf.write(_borderBottom(t, isError: true));
      _log(buf.toString());
    }

    try {
      return super.onError(err, handler);
    } catch (_) {}
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Stops and removes the timer for [req], returning elapsed ms (or null).
  ///
  /// Uses the unique ID stored in [RequestOptions.extra] to avoid hash collisions
  /// when multiple concurrent requests share the same URL and options.
  /// Also flushes any timers older than 60 seconds to prevent memory leaks
  /// when interceptors short-circuit before onResponse/onError fire.
  int? _stopTimer(RequestOptions req) {
    // Flush abandoned timers older than 60 s (e.g. from short-circuited interceptors).
    _timers.removeWhere((_, sw) => sw.elapsed.inSeconds > 60);

    final id = req.extra[_kLogId] as String?;
    if (id == null) return null;
    final sw = _timers.remove(id);
    if (sw == null) return null;
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  /// Prepares request body for display.
  ///
  /// [FormData] is not JSON-serializable, so we convert it manually into a
  /// structured map showing fields and file metadata (name, size in KB).
  dynamic _prepareBody(dynamic data) {
    if (data is FormData) {
      return <String, dynamic>{
        'fields': {for (final f in data.fields) f.key: f.value},
        'files': [
          for (final f in data.files)
            {
              'field': f.key,
              'filename': f.value.filename ?? '(unnamed)',
              'size': '${(f.value.length / 1024).toStringAsFixed(1)} KB',
              'contentType': f.value.contentType?.mimeType ?? 'unknown',
            }
        ],
      };
    }
    return data;
  }

  /// Returns the display value for a header, redacting sensitive keys.
  String _headerValue(String key, String value, LoggerTheme t) {
    if (redactedHeaders.contains(key.toLowerCase())) {
      return '${t.dim}$redactedPlaceholder${t.reset}';
    }
    return '${t.value}$value${t.reset}';
  }

  String _border(String title, LoggerTheme t, {bool isError = false}) {
    final bc = isError ? t.errorTitle : t.sectionBorder;
    final tc = isError ? t.errorTitle : t.sectionTitle;
    final line = '═' * 52;
    return '$bc╔$line${t.reset}\n'
        '$bc║${t.reset}  $tc$title${t.reset}\n'
        '$bc╠$line${t.reset}';
  }

  String _borderBottom(LoggerTheme t, {bool isError = false}) {
    final bc = isError ? t.errorTitle : t.sectionBorder;
    return '$bc╚${'═' * 52}${t.reset}';
  }

  String _field(String label, String value, LoggerTheme t) =>
      '${t.label}  $label ${t.reset}: $value';

  String _formatBody(dynamic data, LoggerTheme t) {
    if (data == null) return '${t.dim}  (empty)${t.reset}';

    String raw;
    if (data is String) {
      try {
        raw = const JsonEncoder.withIndent('  ').convert(jsonDecode(data));
      } catch (_) {
        raw = data;
      }
    } else {
      try {
        raw = const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        raw = data.toString();
      }
    }

    if (raw.length > maxBodyLength) {
      raw =
          '${raw.substring(0, maxBodyLength)}\n  ... [truncated ${raw.length - maxBodyLength} chars]';
    }

    return _colorizeJson(raw, t)
        .split('\n')
        .map((line) => '    $line')
        .join('\n');
  }

  /// Line-by-line JSON colorizer.
  ///
  /// Splits on the first `": "` occurrence so values containing colons
  /// (URLs, timestamps, ISO dates) are handled correctly.
  String _colorizeJson(String json, LoggerTheme t) {
    final result = StringBuffer();
    for (final line in json.split('\n')) {
      final trimmed = line.trimLeft();
      final indent = line.substring(0, line.length - trimmed.length);
      final hasTrailingComma = trimmed.endsWith(',');
      final trimmedNoComma =
          hasTrailingComma ? trimmed.substring(0, trimmed.length - 1) : trimmed;
      final comma = hasTrailingComma ? '${t.dim},${t.reset}' : '';

      // Detect a key-value pair: line starts with a quoted key followed by ": "
      // We split only on the FIRST ": " so values containing colons are safe.
      final colonIndex = _findKeyValueSplit(trimmedNoComma);
      if (colonIndex != -1) {
        final key = trimmedNoComma.substring(0, colonIndex);
        // FIX: clamp the start index so truncation mid-line never causes a
        // RangeError when colonIndex + 2 exceeds trimmedNoComma.length.
        final valueStart = (colonIndex + 2).clamp(0, trimmedNoComma.length);
        final rawVal = trimmedNoComma.substring(valueStart).trim();
        result.writeln(
            '$indent${t.jsonKey}$key${t.reset}: ${_colorizeValue(rawVal, t)}$comma');
      } else {
        result.writeln('$indent${_colorizeValue(trimmedNoComma, t)}$comma');
      }
    }
    return result.toString();
  }

  /// Returns the index of the `: ` separator between a JSON key and its value,
  /// or -1 if this line is not a key-value pair.
  ///
  /// A valid key starts and ends with `"`. We find the closing quote of the key
  /// and then look for `: ` immediately after it.
  int _findKeyValueSplit(String line) {
    if (!line.startsWith('"')) return -1;
    // Walk past the opening quote, find the closing quote (handling escapes).
    var i = 1;
    while (i < line.length) {
      if (line[i] == '\\') {
        i += 2; // skip escaped character
        continue;
      }
      if (line[i] == '"') {
        // Found closing quote of the key. Check for ': ' right after.
        if (i + 1 < line.length && line[i + 1] == ':') {
          return i + 1; // index of ':' — caller slices key and value around it
        }
        return -1;
      }
      i++;
    }
    return -1;
  }

  String _colorizeValue(String val, LoggerTheme t) {
    if (val.startsWith('"') && val.endsWith('"')) {
      return '${t.jsonString}$val${t.reset}';
    }
    if (val == 'true' || val == 'false') {
      return '${t.jsonBool}$val${t.reset}';
    }
    if (val == 'null') {
      return '${t.jsonNull}$val${t.reset}';
    }
    if (RegExp(r'^-?\d+(\.\d+)?([eE][+-]?\d+)?$').hasMatch(val)) {
      return '${t.jsonNumber}$val${t.reset}';
    }
    return '${t.dim}$val${t.reset}';
  }

  String _methodColor(String method) => switch (method) {
        'GET' => theme.methodGet,
        'POST' => theme.methodPost,
        'PUT' => theme.methodPut,
        'DELETE' => theme.methodDelete,
        'PATCH' => theme.methodPatch,
        'HEAD' => theme.methodGet, // safe/idempotent — reuse GET color
        'OPTIONS' => theme.dim, // preflight — low signal, dim it
        'CONNECT' => theme.dim,
        'TRACE' => theme.dim,
        _ => theme.value,
      };

  String _statusColor(int status) {
    if (status >= 200 && status < 300) return theme.statusSuccess;
    if (status >= 300 && status < 400) return theme.statusRedirect;
    return theme.statusError;
  }

  void _log(String message) {
    if (logPrint != null) {
      logPrint!(message);
    } else {
      developer.log(message, name: 'DioLogger');
    }
  }
}
