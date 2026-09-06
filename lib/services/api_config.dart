import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://studenthub-backend-git-main-joshi-sankars-projects.vercel.app/api';
}
