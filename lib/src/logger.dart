// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'theme.dart';
import 'themes.dart';

/// A Dio interceptor that logs HTTP requests, responses, and errors
/// in a structured, Postman-style format with ANSI terminal colors.
///
/// ## Basic usage
/// ```dart
/// import 'package:dio_pretty_logger/dio_pretty_logger.dart';
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
/// > **Note:** ANSI colors render in the **VS Code Debug Console** and most
/// > Unix terminals. In Android Studio install the **ANSI Highlighting** plugin.
final class DioLogger extends Interceptor {
  /// The color theme. Defaults to [LoggerThemes.dark].
  final LoggerTheme theme;

  /// Whether to log outgoing requests. Defaults to `true`.
  final bool logRequest;

  /// Whether to log successful responses. Defaults to `true`.
  final bool logResponse;

  /// Whether to log errors. Defaults to `true`.
  ///
  /// Errors are only logged in [kDebugMode].
  final bool logError;

  /// Maximum body characters before truncation.
  ///
  /// Prevents huge payloads flooding the console. Defaults to `5000`.
  final int maxBodyLength;

  const DioLogger({
    this.theme = LoggerThemes.dark,
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.maxBodyLength = 5000,
  });

  // ─── Request ─────────────────────────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      final t = theme;
      final method = options.method.toUpperCase();
      final url = '${options.baseUrl}${options.path}';
      final buf = StringBuffer();

      buf.writeln(_border('REQUEST', t));
      buf.writeln(_field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

      if (options.queryParameters.isNotEmpty) {
        buf.writeln(_field('Query  ', t.value + options.queryParameters.toString() + t.reset, t));
      }

      if (options.headers.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in options.headers.entries) {
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: ${t.value}${entry.value}${t.reset}');
        }
      }

      if (options.data != null) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(options.data, t));
      }

      buf.write(_borderBottom(t));
      _log(buf.toString());
    }

    return super.onRequest(options, handler);
  }

  // ─── Response ─────────────────────────────────────────────────────────────────

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      final t = theme;
      final status = response.statusCode ?? 0;
      final statusMsg = response.statusMessage ?? '';
      final method = response.requestOptions.method.toUpperCase();
      final url = '${response.requestOptions.baseUrl}${response.requestOptions.path}';
      final buf = StringBuffer();

      buf.writeln(_border('RESPONSE ✓', t));
      buf.writeln(_field('Status ', _statusColor(status) + '$status $statusMsg' + t.reset, t));
      buf.writeln(_field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

      if (response.headers.map.isNotEmpty) {
        buf.writeln(_field('Headers', '', t));
        for (final entry in response.headers.map.entries) {
          buf.writeln('${t.dim}             ${entry.key}${t.reset}: ${t.value}${entry.value.join(', ')}${t.reset}');
        }
      }

      buf.writeln(_field('Body   ', '', t));
      buf.writeln(_formatBody(response.data, t));
      buf.write(_borderBottom(t));
      _log(buf.toString());
    }

    return super.onResponse(response, handler);
  }

  // ─── Error ────────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError && kDebugMode) {
      final t = theme;
      final method = err.requestOptions.method.toUpperCase();
      final url = '${err.requestOptions.baseUrl}${err.requestOptions.path}';
      final status = err.response?.statusCode;
      final buf = StringBuffer();

      buf.writeln(_border('ERROR ✕', t, isError: true));
      buf.writeln(_field('Type   ', t.errorValue + err.type.name + t.reset, t));
      buf.writeln(_field('Method ', _methodColor(method) + method + t.reset, t));
      buf.writeln(_field('URL    ', t.value + url + t.reset, t));

      if (status != null) {
        buf.writeln(_field('Status ', t.errorValue + status.toString() + t.reset, t));
      }
      if (err.message != null) {
        buf.writeln(_field('Message', t.errorValue + err.message! + t.reset, t));
      }
      if (err.response?.data != null) {
        buf.writeln(_field('Body   ', '', t));
        buf.writeln(_formatBody(err.response?.data, t));
      }

      buf.write(_borderBottom(t, isError: true));
      _log(buf.toString());
    }

    return super.onError(err, handler);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────────

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
      raw = '${raw.substring(0, maxBodyLength)}\n  ... [truncated ${raw.length - maxBodyLength} chars]';
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
      final kvMatch = RegExp(r'^(".*?")\s*:\s*(.+?)(?:,)?$').firstMatch(trimmed);

      if (kvMatch != null) {
        final key = kvMatch.group(1)!;
        final rawVal = kvMatch.group(2)!;
        final comma = trimmed.endsWith(',') ? '${t.dim},${t.reset}' : '';
        result.writeln('$indent${t.jsonKey}$key${t.reset}: ${_colorizeValue(rawVal.replaceAll(RegExp(r',$'), ''), t)}$comma');
      } else {
        final valClean = trimmed.replaceAll(RegExp(r',$'), '');
        final comma = trimmed.endsWith(',') ? '${t.dim},${t.reset}' : '';
        result.writeln('$indent${_colorizeValue(valClean, t)}$comma');
      }
    }
    return result.toString();
  }

  String _colorizeValue(String val, LoggerTheme t) {
    if (val.startsWith('"') && val.endsWith('"')) return '${t.jsonString}$val${t.reset}';
    if (val == 'true' || val == 'false') return '${t.jsonBool}$val${t.reset}';
    if (val == 'null') return '${t.jsonNull}$val${t.reset}';
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(val)) return '${t.jsonNumber}$val${t.reset}';
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
    if (status >= 200 && status < 300) return theme.statusSuccess;
    if (status >= 300 && status < 400) return theme.statusRedirect;
    return theme.statusError;
  }

  void _log(String message) => developer.log(message, name: 'DioLogger');
}
