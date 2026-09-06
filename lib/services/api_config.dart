import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'http://192.168.29.54:3000/api';
}
