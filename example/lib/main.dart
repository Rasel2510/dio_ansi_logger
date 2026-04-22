import 'package:dio/dio.dart';
import 'package:dio_ansi_logger/dio_ansi_logger.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ─── Dio setup ────────────────────────────────────────────────────────────────

final dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com'))
  ..interceptors.add(
    // Change theme here:
    //   LoggerThemes.dark      ← default
    //   LoggerThemes.minimal
    //   LoggerThemes.solarized
    //   LoggerThemes.nord
    //   or your own LoggerTheme(...)
    const DioLogger(
      theme: LoggerThemes.dark,
      logRequest: true,
      logResponse: true,
      logError: true,
      maxBodyLength: 5000,
    ),
  );

// ─── App ──────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DioLogger Example',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = 'Tap a button to fire a request';

  Future<void> _get() async {
    setState(() => _status = 'Sending GET...');
    try {
      await dio.get('/posts/1');
      setState(() => _status = '✓ GET /posts/1 — check your debug console');
    } catch (e) {
      setState(() => _status = '✕ Error: $e');
    }
  }

  Future<void> _post() async {
    setState(() => _status = 'Sending POST...');
    try {
      await dio.post('/posts', data: {'title': 'Hello', 'body': 'World', 'userId': 1});
      setState(() => _status = '✓ POST /posts — check your debug console');
    } catch (e) {
      setState(() => _status = '✕ Error: $e');
    }
  }

  Future<void> _error() async {
    setState(() => _status = 'Triggering 404...');
    try {
      await dio.get('/nonexistent-endpoint');
    } on DioException {
      setState(() => _status = '✕ 404 Error — check your debug console');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DioLogger Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton(onPressed: _get, child: const Text('GET /posts/1')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _post, child: const Text('POST /posts')),
            const SizedBox(height: 12),
            FilledButton.tonal(onPressed: _error, child: const Text('Trigger 404 Error')),
          ],
        ),
      ),
    );
  }
}
