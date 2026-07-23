import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_service.dart';

class FcmTokenApi {
  static Future<void> registerToken({
    required String userId,
    required String token,
  }) async {

    final uri = Uri.parse(
      "${ApiService.baseUrl}/api/fcm-tokens",
    );

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": userId,
        "token": token,
      }),
    );

    print("FCM Token 등록 응답 : ${response.statusCode}");
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception("FCM Token 등록 실패");
    }
  }
}