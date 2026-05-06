// ignore_for_file: constant_identifier_names

/// ANSI escape codes for terminal text styling.
///
/// Use these to build custom [LoggerTheme]s.
///
/// Example:
/// ```dart
/// // Bold bright green
/// final color = Ansi.bold + Ansi.brightGreen;
///
/// // Italic underline
/// final style = Ansi.italic + Ansi.underline + Ansi.cyan;
/// ```
abstract final class Ansi {
  Ansi._();

  // ─── Reset ──────────────────────────────────────────────────────────────────

  /// Resets all styling. Always end a colored string with this.
  static const reset = '\x1B[0m';

  // ─── Text styles ────────────────────────────────────────────────────────────

  /// Bold / increased intensity.
  static const bold = '\x1B[1m';

  /// Dim / decreased intensity.
  static const dim = '\x1B[2m';

  /// Italic text. Supported in VS Code Debug Console and most Unix terminals.
  static const italic = '\x1B[3m';

  /// Underline text. Useful for URLs in log output.
  static const underline = '\x1B[4m';

  /// Strikethrough text.
  static const strikethrough = '\x1B[9m';

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

  // ─── Standard background colors ──────────────────────────────────────────────

  static const bgBlack = '\x1B[40m';
  static const bgRed = '\x1B[41m';
  static const bgGreen = '\x1B[42m';
  static const bgYellow = '\x1B[43m';
  static const bgBlue = '\x1B[44m';
  static const bgMagenta = '\x1B[45m';
  static const bgCyan = '\x1B[46m';
  static const bgWhite = '\x1B[47m';

  // ─── Bright background colors ────────────────────────────────────────────────

  static const bgBrightBlack = '\x1B[100m';
  static const bgBrightRed = '\x1B[101m';
  static const bgBrightGreen = '\x1B[102m';
  static const bgBrightYellow = '\x1B[103m';
  static const bgBrightBlue = '\x1B[104m';
  static const bgBrightMagenta = '\x1B[105m';
  static const bgBrightCyan = '\x1B[106m';
  static const bgBrightWhite = '\x1B[107m';
}
