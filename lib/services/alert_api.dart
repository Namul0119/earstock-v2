import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_service.dart';

class AlertApi {
  static const String baseUrl = ApiService.baseUrl;

  static Future<List<dynamic>> getAlerts(String userId) async {
    final response =
        await http.get(Uri.parse("$baseUrl/api/alerts/$userId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("알림 조회 실패");
  }

  static Future<void> deleteAlerts(String userId) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/api/alerts/$userId'),
    );

    if (response.statusCode != 200) {
        throw Exception('알림 삭제 실패');
    }
  }
}