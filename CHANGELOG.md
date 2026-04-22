# Changelog

## 1.0.2

- Added `///` dartdoc comments to `onRequest`, `onResponse`, and `onError` — fixes pub.dev documentation score (was <20%)
- Added extending example to `DioLogger` class documentation
- Fixed: users must declare `base class MyLogger extends DioLogger` (not `final class`) — documented in README and class docs



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
