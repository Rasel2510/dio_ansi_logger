# Changelog

## 1.0.5

- Fixed static analysis warning: added
curly braces to while loop in 
AnsiLog._colorizeJson (lib/src/ansi_log.dart:218)

## 1.0.4

- Added `AnsiLog.enabled` — global on/off switch, auto-off in release builds
  - Defaults to `!bool.fromEnvironment('dart.vm.product')` — debug only
  - Set once in `main.dart`: `AnsiLog.enabled = kDebugMode;`
  - All methods (`debug`, `info`, `success`, `warning`, `error`, `json`) respect this flag
- Added `AnsiLog.json(data)` — pretty prints any `Map` or `List` with full ANSI syntax highlighting
  - Keys in cyan, strings in green, numbers in yellow, booleans in magenta, nulls in dim
  - Supports custom `theme:` and `tag:` parameters
  - Falls back to `debug()` if data is not JSON-encodable

## 1.0.3

- Added `AnsiLog` — a general-purpose static logger for use anywhere in your app
  - `AnsiLog.debug()` — dim white, for verbose dev output
  - `AnsiLog.info()` — cyan, for general info
  - `AnsiLog.success()` — green, for successful operations
  - `AnsiLog.warning()` — yellow, for non-critical issues
  - `AnsiLog.error()` — red, with optional `error:` object
  - All methods support custom `theme:` and `tag:` parameters
- Changed `DioLogger` from `final class` to `base class` — can now be extended outside the package
- Added `///` dartdoc comments to `onRequest`, `onResponse`, and `onError`
- Fixed pub.dev documentation score (was <20%)

## 1.0.2

- Changed `DioLogger` from `final class` to `base class` — can now be extended outside the package

## 1.0.1

- Removed `flutter` dependency — package is now pure Dart, works in Flutter, Dart CLI, and server apps
- Replaced `kDebugMode` with `bool.fromEnvironment('dart.vm.product')` for zero-dependency debug detection
- Tightened `dio` lower bound to `>=5.4.0` to fix downgrade analysis failure (`DioException` undefined)
- Fixed ambiguous reexport warnings from dartdoc with `{@canonicalFor}` annotations
- Updated GitHub repository URLs
- Bumped version to `1.0.1`

## 1.0.0

- Initial release 🎉
- Postman-style structured request / response / error logging
- ANSI color support for VS Code Debug Console & Unix terminals
- 4 built-in themes: `dark`, `minimal`, `solarized`, `nord`
- `matrix` theme — bright green on black 🟢
- Fully customizable `LoggerTheme` with per-field color control
- Configurable body truncation via `maxBodyLength`
- Toggle `logRequest`, `logResponse`, `logError` independently
- Pretty-printed, syntax-highlighted JSON output
- Zero dependencies beyond `dio`
