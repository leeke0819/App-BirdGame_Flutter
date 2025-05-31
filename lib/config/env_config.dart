// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:8080/api/v1';
}
