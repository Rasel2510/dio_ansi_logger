// ignore_for_file: constant_identifier_names

/// ANSI escape codes for terminal text styling.
///
/// Use these to build custom [LoggerTheme]s.
///
/// Example:
/// ```dart
/// // Bold bright green
/// final color = Ansi.bold + Ansi.brightGreen;
/// ```
abstract final class Ansi {
  Ansi._();

  /// Resets all styling. Always end a colored string with this.
  static const reset = '\x1B[0m';

  /// Bold / increased intensity.
  static const bold = '\x1B[1m';

  /// Dim / decreased intensity.
  static const dim = '\x1B[2m';

  // ─── Standard foreground colors ─────────────────────────────────────────────
  static const black = '\x1B[30m';
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const white = '\x1B[37m';

  // ─── Bright foreground colors ────────────────────────────────────────────────
  static const brightBlack = '\x1B[90m';
  static const brightRed = '\x1B[91m';
  static const brightGreen = '\x1B[92m';
  static const brightYellow = '\x1B[93m';
  static const brightBlue = '\x1B[94m';
  static const brightMagenta = '\x1B[95m';
  static const brightCyan = '\x1B[96m';
  static const brightWhite = '\x1B[97m';
}
