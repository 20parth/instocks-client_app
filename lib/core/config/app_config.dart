import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  static const String _defaultApiBaseUrl = 'http://localhost:8000/api';

  static Map<String, String> _env = <String, String>{};

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('.env');
      _env = _parseEnv(raw);
    } catch (_) {
      _env = <String, String>{};
    }
  }

  static String get apiBaseUrl {
    const definedApiBaseUrl = String.fromEnvironment('API_BASE_URL');

    if (definedApiBaseUrl.isNotEmpty) {
      return definedApiBaseUrl;
    }

    final envApiBaseUrl = _env['API_BASE_URL'];
    if (envApiBaseUrl != null && envApiBaseUrl.isNotEmpty) {
      return envApiBaseUrl;
    }

    return _defaultApiBaseUrl;
  }

  static Map<String, String> _parseEnv(String raw) {
    final values = <String, String>{};

    for (final line in const LineSplitter().convert(raw)) {
      final trimmedLine = line.trim();

      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmedLine.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmedLine.substring(0, separatorIndex).trim();
      final value = trimmedLine.substring(separatorIndex + 1).trim();

      if (key.isEmpty) {
        continue;
      }

      values[key] = _stripWrappingQuotes(value);
    }

    return values;
  }

  static String _stripWrappingQuotes(String value) {
    if (value.length >= 2) {
      final startsWithDoubleQuote =
          value.startsWith('"') && value.endsWith('"');
      final startsWithSingleQuote =
          value.startsWith("'") && value.endsWith("'");

      if (startsWithDoubleQuote || startsWithSingleQuote) {
        return value.substring(1, value.length - 1);
      }
    }

    return value;
  }
}
