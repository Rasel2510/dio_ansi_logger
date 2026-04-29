// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'theme.dart';
import 'themes.dart';

/// Whether the app is running in debug mode (not compiled with `-Ddart.vm.product=true`).
const bool _kDebugMode = !bool.fromEnvironment('dart.vm.product');

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
/// ## Disable specific sections
/// ```dart
/// dio.interceptors.add(DioLogger(
///   logRequest:  false,
///   logResponse: true,
///   logError:    true,
/// ));
/// ```
///
/// ## Response time (new in 1.1.0)
/// ```dart
/// dio.interceptors.add(DioLogger(logResponseTime: true));
/// ```
///
/// ## Header redaction (new in 1.1.0)
/// ```dart
/// dio.interceptors.add(DioLogger(
///   redactedHeaders: {'authorization', 'x-api-key', 'cookie'},
/// ));
/// ```
///
/// > **Note:** ANSI colors render in the **VS Code Debug Console** and most
/// > Unix terminals. In Android Studio install the **ANSI Highlighting** plugin.
///
/// ## Extending DioLogger
/// ```dart
/// base class MyLogger extends DioLogger {
///   const MyLogger() : super(theme: LoggerThemes.dark); // const works fine
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
  /// Keyed by [RequestOptions.hashCode] so concurrent requests don't collide.
  static final Map<int, Stopwatch> _timers = {};

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

  const DioLogger({
    this.theme = LoggerThemes.dark,
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.maxBodyLength = 5000,
    this.logResponseTime = true,
    this.redactedHeaders = const {
      'authorization',
      'x-api-key',
      'cookie',
      'set-cookie',
    },
    this.redactedPlaceholder = '[REDACTED]',
  });

  // ─── Request ──────────────────────────────────────────────────────────────

  /// Intercepts outgoing requests and logs method, URL, headers, and body.
  ///
  /// Only runs when [logRequest] is `true`.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      if (logResponseTime) {
        _timers[options.hashCode] = Stopwatch()..start();
      }

      final t = theme;
      final method = options.method.toUpperCase();
      final url = '${options.baseUrl}${options.path}';
      final buf = StringBuffer();

      buf.writeln(_border('REQUEST', t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

      if (options.queryParameters.isNotEmpty) {
        buf.writeln(_field('Query  ',
            t.value + options.queryParameters.toString() + t.reset, t));
      }

      if (options.headers.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in options.headers.entries) {
          final val = _headerValue(entry.key, entry.value?.toString() ?? '', t);
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: $val');
        }
      }

      if (options.data != null) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(options.data, t));
      }

      buf.write(_borderBottom(t));
      _log(buf.toString());
    } else if (logResponseTime) {
      // Still start timer even when request logging is off,
      // so response/error logs can show elapsed time.
      _timers[options.hashCode] = Stopwatch()..start();
    }

    return super.onRequest(options, handler);
  }

  // ─── Response ─────────────────────────────────────────────────────────────

  /// Intercepts successful responses and logs status, method, URL, headers, and body.
  ///
  /// Only runs when [logResponse] is `true`.
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      final elapsed = _stopTimer(response.requestOptions);
      final t = theme;
      final status = response.statusCode ?? 0;
      final statusMsg = response.statusMessage ?? '';
      final method = response.requestOptions.method.toUpperCase();
      final url =
          '${response.requestOptions.baseUrl}${response.requestOptions.path}';
      final buf = StringBuffer();

      buf.writeln(_border('RESPONSE ✓', t));
      buf.writeln(_field(
          'Status ', _statusColor(status) + '$status $statusMsg' + t.reset, t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

      if (elapsed != null) {
        buf.writeln(_field('Time   ', '${t.value}⏱ $elapsed ms${t.reset}', t));
      }

      if (response.headers.map.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in response.headers.map.entries) {
          final raw = entry.value.join(', ');
          final val = _headerValue(entry.key, raw, t);
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: $val');
        }
      }

      buf.writeln(_field('Body   ', '', t));
      buf.writeln(_formatBody(response.data, t));
      buf.write(_borderBottom(t));
      _log(buf.toString());
    } else {
      _stopTimer(response.requestOptions);
    }

    return super.onResponse(response, handler);
  }

  // ─── Error ────────────────────────────────────────────────────────────────

  /// Intercepts errors and logs the type, method, URL, status, and message.
  ///
  /// Only runs when [logError] is `true` and the app is in debug mode.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError && _kDebugMode) {
      final elapsed = _stopTimer(err.requestOptions);
      final t = theme;
      final method = err.requestOptions.method.toUpperCase();
      final url = '${err.requestOptions.baseUrl}${err.requestOptions.path}';
      final status = err.response?.statusCode;
      final buf = StringBuffer();

      buf.writeln(_border('ERROR ✕', t, isError: true));
      buf.writeln(_field('Type   ', t.errorValue + err.type.name + t.reset, t));
      buf.writeln(
          _field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

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
    } else {
      _stopTimer(err.requestOptions);
    }

    return super.onError(err, handler);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Stops and removes the timer for [req], returning elapsed ms (or null).
  int? _stopTimer(RequestOptions req) {
    final sw = _timers.remove(req.hashCode);
    if (sw == null) return null;
    sw.stop();
    return sw.elapsedMilliseconds;
  }

  /// Returns the display value for a header, redacting if necessary.
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
    return '${bc}╔$line${t.reset}\n'
        '${bc}║${t.reset}  $tc$title${t.reset}\n'
        '${bc}╠$line${t.reset}';
  }

  String _borderBottom(LoggerTheme t, {bool isError = false}) {
    final bc = isError ? t.errorTitle : t.sectionBorder;
    return '${bc}╚${'═' * 52}${t.reset}';
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

  /// Simple line-by-line JSON colorizer (no external dependency).
  String _colorizeJson(String json, LoggerTheme t) {
    final result = StringBuffer();
    for (final line in json.split('\n')) {
      final trimmed = line.trimLeft();
      final indent = line.substring(0, line.length - trimmed.length);
      final kvMatch =
          RegExp(r'^(".*?")\s*:\s*(.+?)(?:,)?$').firstMatch(trimmed);

      if (kvMatch != null) {
        final key = kvMatch.group(1)!;
        final rawVal = kvMatch.group(2)!;
        final comma = trimmed.endsWith(',') ? '${t.dim},${t.reset}' : '';
        result.writeln(
            '$indent${t.jsonKey}$key${t.reset}: ${_colorizeValue(rawVal.replaceAll(RegExp(r',$'), ''), t)}$comma');
      } else {
        final valClean = trimmed.replaceAll(RegExp(r',$'), '');
        final comma = trimmed.endsWith(',') ? '${t.dim},${t.reset}' : '';
        result.writeln('$indent${_colorizeValue(valClean, t)}$comma');
      }
    }
    return result.toString();
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
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(val)) {
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
        _ => theme.value,
      };

  String _statusColor(int status) {
    if (status >= 200 && status < 300) {
      return theme.statusSuccess;
    }
    if (status >= 300 && status < 400) {
      return theme.statusRedirect;
    }
    return theme.statusError;
  }

  void _log(String message) => developer.log(message, name: 'DioLogger');
}
