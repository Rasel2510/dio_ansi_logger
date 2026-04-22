import 'dart:developer' as developer;

import 'ansi.dart';
import 'themes.dart';
import 'theme.dart';

/// A general-purpose ANSI colored logger for use anywhere in your app.
///
/// Unlike [DioLogger] which is a Dio interceptor, [AnsiLog] can be called
/// directly from anywhere — repositories, controllers, services, etc.
///
/// ## Usage
/// ```dart
/// import 'package:dio_ansi_logger/dio_ansi_logger.dart';
///
/// AnsiLog.debug('User loaded: $user');
/// AnsiLog.info('Cache hit for key: $key');
/// AnsiLog.success('Payment completed');
/// AnsiLog.warning('Token expiring soon');
/// AnsiLog.error('Login failed', error: e);
/// ```
///
/// ## Custom theme
/// ```dart
/// AnsiLog.debug('message', theme: LoggerThemes.nord);
/// ```
abstract final class AnsiLog {
  AnsiLog._();

  /// Logs a debug message in dim white.
  ///
  /// Use for verbose development output.
  static void debug(
    String message, {
    LoggerTheme theme = LoggerThemes.dark,
    String tag = 'DEBUG',
  }) {
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
}
