import 'ansi.dart';
import 'theme.dart';

/// Built-in [LoggerTheme] presets for [DioLogger].
///
/// Pass one of these to [DioLogger]:
/// ```dart
/// dio.interceptors.add(DioLogger(theme: LoggerThemes.minimal));
/// ```
abstract final class LoggerThemes {
  LoggerThemes._();

  /// Dark terminal theme — Postman-inspired with vivid ANSI colors.
  /// This is the default theme used when no [theme] is specified.
  static const dark = LoggerTheme(
    sectionBorder: Ansi.dim + Ansi.cyan,
    sectionTitle: Ansi.bold + Ansi.brightCyan,
    label: Ansi.dim + Ansi.white,
    value: Ansi.brightWhite,
    methodGet: Ansi.bold + Ansi.brightGreen,
    methodPost: Ansi.bold + Ansi.brightBlue,
    methodPut: Ansi.bold + Ansi.brightYellow,
    methodDelete: Ansi.bold + Ansi.brightRed,
    methodPatch: Ansi.bold + Ansi.brightMagenta,
    statusSuccess: Ansi.bold + Ansi.brightGreen,
    statusRedirect: Ansi.bold + Ansi.brightYellow,
    statusError: Ansi.bold + Ansi.brightRed,
    jsonKey: Ansi.brightCyan,
    jsonString: Ansi.brightGreen,
    jsonNumber: Ansi.brightYellow,
    jsonBool: Ansi.brightMagenta,
    jsonNull: Ansi.dim + Ansi.white,
    errorTitle: Ansi.bold + Ansi.brightRed,
    errorValue: Ansi.red,
    dim: Ansi.dim + Ansi.white,
    reset: Ansi.reset,
  );

  /// Minimal — only essential colors; less visual noise.
  static const minimal = LoggerTheme(
    sectionBorder: Ansi.dim + Ansi.white,
    sectionTitle: Ansi.bold + Ansi.white,
    label: Ansi.dim + Ansi.white,
    value: Ansi.white,
    methodGet: Ansi.bold + Ansi.green,
    methodPost: Ansi.bold + Ansi.blue,
    methodPut: Ansi.bold + Ansi.yellow,
    methodDelete: Ansi.bold + Ansi.red,
    methodPatch: Ansi.bold + Ansi.magenta,
    statusSuccess: Ansi.green,
    statusRedirect: Ansi.yellow,
    statusError: Ansi.red,
    jsonKey: Ansi.cyan,
    jsonString: Ansi.white,
    jsonNumber: Ansi.yellow,
    jsonBool: Ansi.magenta,
    jsonNull: Ansi.dim + Ansi.white,
    errorTitle: Ansi.bold + Ansi.red,
    errorValue: Ansi.red,
    dim: Ansi.dim + Ansi.white,
    reset: Ansi.reset,
  );

  /// Solarized — warm amber + teal palette.
  static const solarized = LoggerTheme(
    sectionBorder: Ansi.dim + Ansi.yellow,
    sectionTitle: Ansi.bold + Ansi.yellow,
    label: Ansi.dim + Ansi.cyan,
    value: Ansi.white,
    methodGet: Ansi.bold + Ansi.green,
    methodPost: Ansi.bold + Ansi.blue,
    methodPut: Ansi.bold + Ansi.yellow,
    methodDelete: Ansi.bold + Ansi.red,
    methodPatch: Ansi.bold + Ansi.magenta,
    statusSuccess: Ansi.bold + Ansi.green,
    statusRedirect: Ansi.bold + Ansi.yellow,
    statusError: Ansi.bold + Ansi.red,
    jsonKey: Ansi.cyan,
    jsonString: Ansi.green,
    jsonNumber: Ansi.magenta,
    jsonBool: Ansi.red,
    jsonNull: Ansi.dim + Ansi.white,
    errorTitle: Ansi.bold + Ansi.red,
    errorValue: Ansi.red,
    dim: Ansi.dim + Ansi.white,
    reset: Ansi.reset,
  );

  /// Nord — cool blue-grey Arctic palette.
  static const nord = LoggerTheme(
    sectionBorder: Ansi.dim + Ansi.blue,
    sectionTitle: Ansi.bold + Ansi.brightBlue,
    label: Ansi.dim + Ansi.white,
    value: Ansi.brightWhite,
    methodGet: Ansi.bold + Ansi.brightGreen,
    methodPost: Ansi.bold + Ansi.brightBlue,
    methodPut: Ansi.bold + Ansi.brightYellow,
    methodDelete: Ansi.bold + Ansi.brightRed,
    methodPatch: Ansi.bold + Ansi.brightMagenta,
    statusSuccess: Ansi.bold + Ansi.brightGreen,
    statusRedirect: Ansi.bold + Ansi.brightYellow,
    statusError: Ansi.bold + Ansi.brightRed,
    jsonKey: Ansi.brightBlue,
    jsonString: Ansi.brightGreen,
    jsonNumber: Ansi.brightMagenta,
    jsonBool: Ansi.brightRed,
    jsonNull: Ansi.dim + Ansi.white,
    errorTitle: Ansi.bold + Ansi.brightRed,
    errorValue: Ansi.red,
    dim: Ansi.dim + Ansi.white,
    reset: Ansi.reset,
  );

  /// Matrix — full bright green on black, like the iconic terminal rain.
  ///
  /// Every element glows green; errors burn in red for maximum contrast.
  static const matrix = LoggerTheme(
    sectionBorder: Ansi.bold + Ansi.brightGreen,
    sectionTitle: Ansi.bold + Ansi.brightGreen,
    label: Ansi.dim + Ansi.green,
    value: Ansi.brightGreen,
    methodGet: Ansi.bold + Ansi.brightGreen,
    methodPost: Ansi.bold + Ansi.brightGreen,
    methodPut: Ansi.bold + Ansi.brightGreen,
    methodDelete: Ansi.bold + Ansi.brightRed,
    methodPatch: Ansi.bold + Ansi.green,
    statusSuccess: Ansi.bold + Ansi.brightGreen,
    statusRedirect: Ansi.bold + Ansi.green,
    statusError: Ansi.bold + Ansi.brightRed,
    jsonKey: Ansi.bold + Ansi.brightGreen,
    jsonString: Ansi.green,
    jsonNumber: Ansi.brightGreen,
    jsonBool: Ansi.bold + Ansi.brightGreen,
    jsonNull: Ansi.dim + Ansi.green,
    errorTitle: Ansi.bold + Ansi.brightRed,
    errorValue: Ansi.brightRed,
    dim: Ansi.dim + Ansi.green,
    reset: Ansi.reset,
  );
}
