import 'package:http/http.dart' as http;

import '../config/api_service.dart';

class ServerHealthService {
  static Future<bool> isServerAvailable() async {
    try {
      final uri = Uri.parse(
        '${ApiService.baseUrl}/api/health',
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 3),
          );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}