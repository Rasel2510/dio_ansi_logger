import 'dart:convert';
import 'dart:developer' as developer;

import 'ansi.dart';
import 'theme.dart';
import 'themes.dart';

/// A general-purpose ANSI colored logger for use anywhere in your app.
///
/// Unlike [DioLogger] which is a Dio interceptor, [AnsiLog] can be called
/// directly from anywhere — repositories, controllers, services, etc.
///
/// ## Auto-disable in release
/// Set [enabled] once in `main.dart` and all logs are silenced in release:
/// ```dart
/// import 'package:flutter/foundation.dart';
///
/// void main() {
///   AnsiLog.enabled = kDebugMode; // auto off in release
///   runApp(const MyApp());
/// }
/// ```
///
/// ## Usage
/// ```dart
/// AnsiLog.debug('User loaded: $user');
/// AnsiLog.info('Cache hit for key: $key');
/// AnsiLog.success('Payment completed');
/// AnsiLog.warning('Token expiring soon');
/// AnsiLog.error('Login failed', error: e);
/// AnsiLog.json(response.data, tag: 'GetTourApi');
/// ```
///
/// ## Custom theme
/// ```dart
/// AnsiLog.debug('message', theme: LoggerThemes.nord);
/// ```
abstract final class AnsiLog {
  AnsiLog._();

  /// Whether logging is enabled.
  ///
  /// Set to `kDebugMode` in `main.dart` to automatically disable in release:
  /// ```dart
  /// AnsiLog.enabled = kDebugMode;
  /// ```
  ///
  /// Defaults to `true` for backwards compatibility.
  static bool enabled = !bool.fromEnvironment('dart.vm.product');

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Logs a debug message in dim white.
  ///
  /// Use for verbose development output.
  static void debug(
    String message, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'DEBUG',
  }) {
    if (!enabled) return;
    _log(
      tag: tag,
      message: message,
      labelColor: theme.dim,
      messageColor: theme.value,
      theme: theme,
    );
  }

  /// Logs an info message in cyan.
  ///
  /// Use for general informational output.
  static void info(
    String message, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'INFO',
  }) {
    if (!enabled) return;
    _log(
      tag: tag,
      message: message,
      labelColor: Ansi.bold + Ansi.brightCyan,
      messageColor: theme.value,
      theme: theme,
    );
  }

  /// Logs a success message in green.
  ///
  /// Use for confirming successful operations.
  static void success(
    String message, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'SUCCESS',
  }) {
    if (!enabled) return;
    _log(
      tag: tag,
      message: message,
      labelColor: Ansi.bold + Ansi.brightGreen,
      messageColor: theme.statusSuccess,
      theme: theme,
    );
  }

  /// Logs a warning message in yellow.
  ///
  /// Use for non-critical issues that may need attention.
  static void warning(
    String message, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'WARNING',
  }) {
    if (!enabled) return;
    _log(
      tag: tag,
      message: message,
      labelColor: Ansi.bold + Ansi.brightYellow,
      messageColor: theme.statusRedirect,
      theme: theme,
    );
  }

  /// Logs an error message in red, with an optional error object.
  ///
  /// Use for exceptions and failures.
  /// ```dart
  /// AnsiLog.error('Login failed', error: e);
  /// ```
  static void error(
    String message, {
    Object? error,
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'ERROR',
  }) {
    if (!enabled) return;
    final buf = StringBuffer();
    buf.write(message);
    if (error != null) {
      buf.write('\n  ${theme.dim}↳ ${theme.errorValue}$error${theme.reset}');
    }
    _log(
      tag: tag,
      message: buf.toString(),
      labelColor: Ansi.bold + Ansi.brightRed,
      messageColor: theme.errorValue,
      theme: theme,
    );
  }

  /// Pretty prints any [Map] or [List] with ANSI syntax highlighting.
  ///
  /// Ideal for logging raw API responses:
  /// ```dart
  /// AnsiLog.json(response.data, tag: 'GetTourApi');
  /// ```
  ///
  /// Output is colorized JSON with:
  /// - Keys in cyan
  /// - Strings in green
  /// - Numbers in yellow
  /// - Booleans in magenta
  /// - Nulls in dim
  static void json(
    dynamic data, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'JSON',
  }) {
    if (!enabled) return;
    try {
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      final colorized = _colorizeJson(pretty, theme);
      developer.log(
        '${Ansi.bold + Ansi.brightCyan}[$tag]${theme.reset} ${theme.dim}│${theme.reset}\n$colorized',
        name: 'AnsiLog',
      );
    } catch (_) {
      debug(data.toString(), tag: tag, theme: theme);
    }
  }

  // ─── Internal ──────────────────────────────────────────────────────────────

  static void _log({
    required String tag,
    required String message,
    required String labelColor,
    required String messageColor,
    required LoggerTheme theme,
  }) {
    final reset = theme.reset;
    final dim = theme.dim;
    final output =
        '$labelColor[$tag]$reset $dim│$reset $messageColor$message$reset';
    developer.log(output, name: 'AnsiLog');
  }

  static String _colorizeJson(String json, LoggerTheme t) {
    final buf = StringBuffer();
    final reset = t.reset;
    var i = 0;
    while (i < json.length) {
      final ch = json[i];

      // String
      if (ch == '"') {
        final start = i;
        i++;
        while (i < json.length && json[i] != '"') {
          if (json[i] == '\\') i++;
          i++;
        }
        i++;
        final token = json.substring(start, i);
        // Check if next non-whitespace char is ':' → it's a key
        var j = i;
        while (j < json.length && (json[j] == ' ' || json[j] == '\n')) j++;
        if (j < json.length && json[j] == ':') {
          buf.write('${t.jsonKey}$token$reset');
        } else {
          buf.write('${t.jsonString}$token$reset');
        }
        continue;
      }

      // Number
      if (ch == '-' || (ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57)) {
        final start = i;
        while (i < json.length &&
            (json[i] == '-' ||
                json[i] == '.' ||
                json[i] == 'e' ||
                json[i] == 'E' ||
                json[i] == '+' ||
                (json[i].codeUnitAt(0) >= 48 &&
                    json[i].codeUnitAt(0) <= 57))) {
          i++;
        }
        buf.write('${t.jsonNumber}${json.substring(start, i)}$reset');
        continue;
      }

      // Boolean true
      if (json.startsWith('true', i)) {
        buf.write('${t.jsonBool}true$reset');
        i += 4;
        continue;
      }

      // Boolean false
      if (json.startsWith('false', i)) {
        buf.write('${t.jsonBool}false$reset');
        i += 5;
        continue;
      }

      // Null
      if (json.startsWith('null', i)) {
        buf.write('${t.jsonNull}null$reset');
        i += 4;
        continue;
      }

      buf.write(ch);
      i++;
    }
    return buf.toString();
  }
}

