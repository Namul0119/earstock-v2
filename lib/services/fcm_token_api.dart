import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_service.dart';
import 'token_service.dart';

import '../exceptions/api_exceptions.dart';

class FcmTokenApi {
  static final TokenService _tokenService =
      TokenService();

  static Future<void> registerToken({
    required String token,
  }) async {
    final accessToken =
        await _tokenService.getAccessToken();

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw UnauthorizedException(
        '로그인이 필요합니다.',
      );
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/api/fcm-tokens',
    );

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type':
            'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'token': token,
      }),
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      'FCM Token 등록 응답: ${response.statusCode}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    _handleUnauthorized(
      response.statusCode,
    );

    throw Exception(
      responseText.isNotEmpty
          ? responseText
          : 'FCM Token 등록 실패',
    );
  }

  static Future<void> unregisterToken({
    required String token,
  }) async {
    final accessToken =
        await _tokenService.getAccessToken();

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw Exception('로그인이 필요합니다.');
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/api/fcm-tokens',
    );

    final response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type':
            'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'token': token,
      }),
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      'FCM Token 등록 해제 응답: '
      '${response.statusCode}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    _handleUnauthorized(
      response.statusCode,
    );

    throw Exception(
      responseText.isNotEmpty
          ? responseText
          : 'FCM Token 등록 해제 실패',
    );
  }

  static void _handleUnauthorized(
    int statusCode,
  ) {
    if (statusCode == 401) {
      throw UnauthorizedException();
    }
  }
}