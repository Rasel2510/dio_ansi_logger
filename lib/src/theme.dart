import 'ansi.dart';

/// Defines the ANSI color palette used by [DioLogger].
///
/// Each field is an ANSI escape string (e.g. `'\x1B[1m\x1B[92m'`).
/// Use the [Ansi] constants as building blocks, or write raw codes.
///
/// ## Example — custom theme
/// ```dart
/// const myTheme = LoggerTheme(
///   sectionBorder:  Ansi.dim + Ansi.magenta,
///   sectionTitle:   Ansi.bold + Ansi.brightMagenta,
///   label:          Ansi.dim + Ansi.white,
///   value:          Ansi.brightWhite,
///   underline:      Ansi.underline,
///   methodGet:      Ansi.bold + Ansi.brightGreen,
///   methodPost:     Ansi.bold + Ansi.brightBlue,
///   methodPut:      Ansi.bold + Ansi.brightYellow,
///   methodDelete:   Ansi.bold + Ansi.brightRed,
///   methodPatch:    Ansi.bold + Ansi.brightMagenta,
///   statusSuccess:  Ansi.bold + Ansi.brightGreen,
///   statusRedirect: Ansi.bold + Ansi.brightYellow,
///   statusError:    Ansi.bold + Ansi.brightRed,
///   jsonKey:        Ansi.brightCyan,
///   jsonString:     Ansi.brightGreen,
///   jsonNumber:     Ansi.brightYellow,
///   jsonBool:       Ansi.brightMagenta,
///   jsonNull:       Ansi.dim + Ansi.white,
///   errorTitle:     Ansi.bold + Ansi.brightRed,
///   errorValue:     Ansi.red,
///   dim:            Ansi.dim + Ansi.white,
///   reset:          Ansi.reset,
/// );
/// ```
///
/// ## Tweaking a built-in theme with copyWith
/// ```dart
/// final myTheme = LoggerThemes.dark.copyWith(
///   errorTitle: Ansi.bold + Ansi.brightMagenta,
///   jsonKey: Ansi.brightYellow,
/// );
/// ```
final class LoggerTheme {
  /// Color of the `╔═══╗` border lines.
  final String sectionBorder;

  /// Color of the section title (e.g. `REQUEST`, `RESPONSE ✓`).
  final String sectionTitle;

  /// Color of field labels (e.g. `Method :`, `URL :`).
  final String label;

  /// Default color for plain field values.
  final String value;

  /// Underline style applied to URLs.
  ///
  /// Set to `''` (empty string) to disable URL underlining.
  final String underline;

  /// Color for the GET method badge.
  final String methodGet;

  /// Color for the POST method badge.
  final String methodPost;

  /// Color for the PUT method badge.
  final String methodPut;

  /// Color for the DELETE method badge.
  final String methodDelete;

  /// Color for the PATCH method badge.
  final String methodPatch;

  /// Color for 2xx status codes.
  final String statusSuccess;

  /// Color for 3xx status codes.
  final String statusRedirect;

  /// Color for 4xx / 5xx status codes.
  final String statusError;

  /// Color for JSON object/array keys.
  final String jsonKey;

  /// Color for JSON string values.
  final String jsonString;

  /// Color for JSON number values.
  final String jsonNumber;

  /// Color for JSON boolean values (`true` / `false`).
  final String jsonBool;

  /// Color for JSON `null` values.
  final String jsonNull;

  /// Color for the error section title and border.
  final String errorTitle;

  /// Color for error field values (message, type, etc.).
  final String errorValue;

  /// Dim/muted color used for punctuation and secondary info.
  final String dim;

  /// ANSI reset code — always keep as [Ansi.reset].
  final String reset;

  const LoggerTheme({
    required this.sectionBorder,
    required this.sectionTitle,
    required this.label,
    required this.value,
    required this.underline,
    required this.methodGet,
    required this.methodPost,
    required this.methodPut,
    required this.methodDelete,
    required this.methodPatch,
    required this.statusSuccess,
    required this.statusRedirect,
    required this.statusError,
    required this.jsonKey,
    required this.jsonString,
    required this.jsonNumber,
    required this.jsonBool,
    required this.jsonNull,
    required this.errorTitle,
    required this.errorValue,
    required this.dim,
    required this.reset,
  });

  /// Returns a copy of this theme with the given fields replaced.
  ///
  /// Useful for tweaking a single color of a built-in theme without
  /// having to specify all fields from scratch.
  ///
  /// ```dart
  /// final myTheme = LoggerThemes.dark.copyWith(
  ///   errorTitle: Ansi.bold + Ansi.brightMagenta,
  /// );
  /// ```
  LoggerTheme copyWith({
    String? sectionBorder,
    String? sectionTitle,
    String? label,
    String? value,
    String? underline,
    String? methodGet,
    String? methodPost,
    String? methodPut,
    String? methodDelete,
    String? methodPatch,
    String? statusSuccess,
    String? statusRedirect,
    String? statusError,
    String? jsonKey,
    String? jsonString,
    String? jsonNumber,
    String? jsonBool,
    String? jsonNull,
    String? errorTitle,
    String? errorValue,
    String? dim,
    String? reset,
  }) =>
      LoggerTheme(
        sectionBorder: sectionBorder ?? this.sectionBorder,
        sectionTitle: sectionTitle ?? this.sectionTitle,
        label: label ?? this.label,
        value: value ?? this.value,
        underline: underline ?? this.underline,
        methodGet: methodGet ?? this.methodGet,
        methodPost: methodPost ?? this.methodPost,
        methodPut: methodPut ?? this.methodPut,
        methodDelete: methodDelete ?? this.methodDelete,
        methodPatch: methodPatch ?? this.methodPatch,
        statusSuccess: statusSuccess ?? this.statusSuccess,
        statusRedirect: statusRedirect ?? this.statusRedirect,
        statusError: statusError ?? this.statusError,
        jsonKey: jsonKey ?? this.jsonKey,
        jsonString: jsonString ?? this.jsonString,
        jsonNumber: jsonNumber ?? this.jsonNumber,
        jsonBool: jsonBool ?? this.jsonBool,
        jsonNull: jsonNull ?? this.jsonNull,
        errorTitle: errorTitle ?? this.errorTitle,
        errorValue: errorValue ?? this.errorValue,
        dim: dim ?? this.dim,
        reset: reset ?? this.reset,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggerTheme &&
          sectionBorder == other.sectionBorder &&
          sectionTitle == other.sectionTitle &&
          label == other.label &&
          value == other.value &&
          underline == other.underline &&
          methodGet == other.methodGet &&
          methodPost == other.methodPost &&
          methodPut == other.methodPut &&
          methodDelete == other.methodDelete &&
          methodPatch == other.methodPatch &&
          statusSuccess == other.statusSuccess &&
          statusRedirect == other.statusRedirect &&
          statusError == other.statusError &&
          jsonKey == other.jsonKey &&
          jsonString == other.jsonString &&
          jsonNumber == other.jsonNumber &&
          jsonBool == other.jsonBool &&
          jsonNull == other.jsonNull &&
          errorTitle == other.errorTitle &&
          errorValue == other.errorValue &&
          dim == other.dim &&
          reset == other.reset;

  @override
  int get hashCode => Object.hashAll([
        sectionBorder,
        sectionTitle,
        label,
        value,
        underline,
        methodGet,
        methodPost,
        methodPut,
        methodDelete,
        methodPatch,
        statusSuccess,
        statusRedirect,
        statusError,
        jsonKey,
        jsonString,
        jsonNumber,
        jsonBool,
        jsonNull,
        errorTitle,
        errorValue,
        dim,
        reset,
      ]);
}
