import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_service.dart';
import 'token_service.dart';

class AlertApi {
  static const String baseUrl = ApiService.baseUrl;

  static final TokenService _tokenService =
      TokenService();

  static Future<List<dynamic>> getAlerts() async {
    final accessToken =
        await _tokenService.getAccessToken();

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/alerts'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(
        utf8.decode(response.bodyBytes),
      );
    }

    throw Exception('알림 조회 실패');
  }

  static Future<void> deleteAlerts() async {
    final accessToken =
        await _tokenService.getAccessToken();

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/api/alerts'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('알림 삭제 실패');
    }
  }
}