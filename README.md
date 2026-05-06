# dio_ansi_logger

A beautiful, **Postman-style** Dio interceptor that logs HTTP requests and responses with **ANSI colors**, structured formatting, and fully customizable themes — straight to your Flutter debug console.

---

## ✨ Features

- 📦 **Structured output** — bordered sections for REQUEST, RESPONSE ✓ and ERROR ✕  
- 🎨 **5 built-in themes** — `dark`, `minimal`, `solarized`, `nord`, `matrix`  
- 🖌️ **Fully customizable** — control the color of every single field  
- 🌈 **Syntax-highlighted JSON** — keys, strings, numbers, booleans and nulls each get their own color  
- ⏱ **Response time tracking** — see exactly how long every request takes  
- 🔒 **Header redaction** — sensitive headers masked automatically  
- 🔍 **Smart filtering** — silence logs for specific endpoints  
- 🧩 **Granular logging control** — toggle headers/body independently  
- 📝 **Custom log output** — send logs to Talker, Firebase, or anywhere  
- ✂️ **Body truncation** — prevent huge payloads flooding the console  
- 🎯 **Improved FormData support** — readable fields + file metadata  
- 🔢 **Scientific number support** — handles `1e10`, `2.3E-4`  
- 🌐 **Extended HTTP methods** — HEAD, OPTIONS, CONNECT, TRACE  
- 🔗 **Underlined URLs** — better readability in logs  
- 0️⃣ **Zero extra dependencies** — only requires `dio`  

---

## 📸 Output Preview

```
╔════════════════════════════════════════════════════
║  REQUEST
╠════════════════════════════════════════════════════
  Method  : POST
  URL     : https://api.example.com/auth/login
  Headers :
             content-type: application/json
             authorization: [REDACTED]
  Body    :
    {
      "email": "rafi@example.com",
      "password": "secret"
    }
╚════════════════════════════════════════════════════

╔════════════════════════════════════════════════════
║  RESPONSE ✓
╠════════════════════════════════════════════════════
  Status  : 200 OK
  Method  : POST
  URL     : https://api.example.com/auth/login
  Time    : ⏱ 213 ms
  Body    :
    {
      "token": "eyJhbGciOiJIUzI1NiJ9...",
      "expiresIn": 3600
    }
╚════════════════════════════════════════════════════
```

> Colors render in the **VS Code Debug Console** and Unix terminals.  
> Android Studio users: install the **ANSI Highlighting** plugin.

---

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dio_ansi_logger: ^1.1.0
```

Then run:

```bash
flutter pub get
```

---

## 🔧 Usage

```dart
import 'package:dio/dio.dart';
import 'package:dio_ansi_logger/dio_ansi_logger.dart';

final dio = Dio();
dio.interceptors.add(const DioLogger());
```

That's it. Every request, response and error will now be logged beautifully.

---

## 🎨 Switching Themes

```dart
// Dark terminal — Postman-inspired (default)
dio.interceptors.add(const DioLogger());
dio.interceptors.add(const DioLogger(theme: LoggerThemes.dark));

// Other built-in themes
dio.interceptors.add(const DioLogger(theme: LoggerThemes.minimal));
dio.interceptors.add(const DioLogger(theme: LoggerThemes.solarized));
dio.interceptors.add(const DioLogger(theme: LoggerThemes.nord));
dio.interceptors.add(const DioLogger(theme: LoggerThemes.matrix)); // 🟢 bright green
```

---

## 🖌️ Custom Theme

Use `LoggerTheme` with `Ansi` constants to build your own palette:

```dart
import 'package:dio_ansi_logger/dio_ansi_logger.dart';

const myTheme = LoggerTheme(
  sectionBorder:   Ansi.dim + Ansi.magenta,
  sectionTitle:    Ansi.bold + Ansi.brightMagenta,
  label:           Ansi.dim + Ansi.white,
  value:           Ansi.brightWhite,
  methodGet:       Ansi.bold + Ansi.brightGreen,
  methodPost:      Ansi.bold + Ansi.brightBlue,
  methodPut:       Ansi.bold + Ansi.brightYellow,
  methodDelete:    Ansi.bold + Ansi.brightRed,
  methodPatch:     Ansi.bold + Ansi.brightMagenta,
  statusSuccess:   Ansi.bold + Ansi.brightGreen,
  statusRedirect:  Ansi.bold + Ansi.brightYellow,
  statusError:     Ansi.bold + Ansi.brightRed,
  jsonKey:         Ansi.brightCyan,
  jsonString:      Ansi.brightGreen,
  jsonNumber:      Ansi.brightYellow,
  jsonBool:        Ansi.brightMagenta,
  jsonNull:        Ansi.dim + Ansi.white,
  errorTitle:      Ansi.bold + Ansi.brightRed,
  errorValue:      Ansi.red,
  dim:             Ansi.dim + Ansi.white,
  reset:           Ansi.reset,   // ← always keep this as Ansi.reset
);

dio.interceptors.add(const DioLogger(theme: myTheme));
```

### Ansi color reference

| Code | Color | Code | Color |
|------|-------|------|-------|
| `Ansi.red` | Red | `Ansi.brightRed` | Bright Red |
| `Ansi.green` | Green | `Ansi.brightGreen` | Bright Green |
| `Ansi.yellow` | Yellow | `Ansi.brightYellow` | Bright Yellow |
| `Ansi.blue` | Blue | `Ansi.brightBlue` | Bright Blue |
| `Ansi.magenta` | Magenta | `Ansi.brightMagenta` | Bright Magenta |
| `Ansi.cyan` | Cyan | `Ansi.brightCyan` | Bright Cyan |
| `Ansi.white` | White | `Ansi.brightWhite` | Bright White |
| `Ansi.bold` | **Bold** | `Ansi.dim` | Dim |

Combine them: `Ansi.bold + Ansi.brightGreen` = bold bright green.

---

## ⚙️ Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `theme` | `LoggerTheme` | `LoggerThemes.dark` | Color theme |
| `logRequest` | `bool` | `true` | Log outgoing requests |
| `logResponse` | `bool` | `true` | Log successful responses |
| `logError` | `bool` | `true` | Log errors (debug mode only) |
| `maxBodyLength` | `int` | `5000` | Max body chars before truncation |
| `logResponseTime` | `bool` | `true` | Show ⏱ elapsed ms on response/error |
| `redactedHeaders` | `Set<String>` | `{authorization, x-api-key, cookie, set-cookie}` | Headers to mask |
| `redactedPlaceholder` | `String` | `[REDACTED]` | Value shown instead of redacted header |

---

## 🔒 Header Redaction

Sensitive headers are masked by default. You can customise which headers are redacted:

```dart
dio.interceptors.add(const DioLogger(
  // Add to or replace the default set
  redactedHeaders: {'authorization', 'x-api-key', 'cookie', 'x-refresh-token'},
  redactedPlaceholder: '••••••',   // optional — defaults to [REDACTED]
));
```

Matching is **case-insensitive** — `Authorization` and `authorization` are both caught.

To disable redaction entirely, pass an empty set:

```dart
dio.interceptors.add(const DioLogger(redactedHeaders: {}));
```

---

## ⏱ Response Time

Elapsed time is shown automatically on the `Time` field of every RESPONSE and ERROR log.  
Disable it with:

```dart
dio.interceptors.add(const DioLogger(logResponseTime: false));
```

---

## 📝 AnsiLog — General Purpose Logger

`AnsiLog` can be called from anywhere — repositories, controllers, services, etc.

```dart
// Disable in release builds (call once in main.dart)
AnsiLog.enabled = kDebugMode;

AnsiLog.debug('User loaded: $user');
AnsiLog.info('Cache hit for key: $key');
AnsiLog.success('Payment completed');
AnsiLog.warning('Token expiring soon');
AnsiLog.error('Login failed', error: e);
AnsiLog.json(response.data, tag: 'GetTourApi');
```

---

## 📄 License

MIT © 2026 [RASEL](https://github.com/Rasel2510)
