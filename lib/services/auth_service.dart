import 'dart:convert';

import 'package:http/http.dart' as http;

import 'token_service.dart';

class AuthService {
    AuthService({
        required this.baseUrl,
        TokenService? tokenService,
    }) : _tokenService = tokenService ?? TokenService();

    final String baseUrl;
    final TokenService _tokenService;

    Future<void> login({
        required String loginId,
        required String password,
    }) async {
        final uri = Uri.parse('$baseUrl/api/auth/login');

        final response = await http.post(
        uri,
        headers: {
            'Content-Type': 'application/json',
        },
        body: jsonEncode({
            'loginId': loginId.trim(),
            'password': password,
        }),
        );

        final Map<String, dynamic> data;

        try {
        data = jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        } catch (_) {
        throw Exception('서버 응답을 처리할 수 없습니다.');
        }

        if (response.statusCode != 200) {
        throw Exception(
            data['message']?.toString() ?? '로그인에 실패했습니다.',
        );
        }

        final accessToken = data['accessToken']?.toString();

        if (accessToken == null || accessToken.isEmpty) {
        throw Exception('서버에서 JWT를 받지 못했습니다.');
        }

        await _tokenService.saveAccessToken(accessToken);
    }

    Future<void> signup({
        required String loginId,
        required String password,
        required String nickname,
    }) async {
    final uri = Uri.parse(
        '$baseUrl/api/auth/signup',
    );

    final response = await http.post(
        uri,
        headers: {
        'Content-Type': 'application/json',
        },
        body: jsonEncode({
        'loginId': loginId.trim(),
        'password': password,
        'nickname': nickname.trim(),
        }),
    );

    if (response.statusCode == 200) {
        return;
    }

    String message = '회원가입에 실패했습니다.';

    try {
        final data = jsonDecode(
        utf8.decode(response.bodyBytes),
        );

        if (data is Map &&
            data['message'] != null) {
        message = data['message'].toString();
        } else if (data is String) {
        message = data;
        }
    } catch (_) {
        final responseText =
            utf8.decode(response.bodyBytes);

        if (responseText.isNotEmpty) {
        message = responseText;
        }
    }

    throw Exception(message);
    }

    Future<void> logout() async {
        await _tokenService.deleteAccessToken();
    }

    Future<bool> isLoggedIn() async {
        return _tokenService.hasAccessToken();
    }
}