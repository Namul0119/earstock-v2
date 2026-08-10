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

    Future<void> changeLoginId({
        required String currentPassword,
        required String newLoginId,
    }) async {
        final token =
            await _tokenService.getAccessToken();

        if (token == null || token.isEmpty) {
            throw Exception('로그인이 필요합니다.');
        }

        final uri = Uri.parse(
            '$baseUrl/api/auth/login-id',
        );

        final response = await http.put(
            uri,
            headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            },
            body: jsonEncode({
            'currentPassword': currentPassword,
            'newLoginId': newLoginId.trim(),
            }),
        );

        if (response.statusCode >= 200 &&
            response.statusCode < 300) {
            return;
        }

        String message = '아이디 변경에 실패했습니다.';

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

    Future<void> changePassword({
        required String currentPassword,
        required String newPassword,
    }) async {
        final token =
            await _tokenService.getAccessToken();

        if (token == null || token.isEmpty) {
            throw Exception('로그인이 필요합니다.');
        }

        final uri = Uri.parse(
            '$baseUrl/api/auth/password',
        );

        final response = await http.put(
            uri,
            headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            },
            body: jsonEncode({
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            }),
        );

        if (response.statusCode >= 200 &&
            response.statusCode < 300) {
            return;
        }

        String message = '비밀번호 변경에 실패했습니다.';

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

    Future<bool> validateCurrentSession() async {
        final token =
            await _tokenService.getAccessToken();

        if (token == null || token.isEmpty) {
            return false;
        }

        final uri = Uri.parse(
            '$baseUrl/api/auth/me',
        );

        try {
            final response = await http.get(
            uri,
            headers: {
                'Authorization': 'Bearer $token',
            },
            );

            if (response.statusCode == 200) {
            return true;
            }

            if (response.statusCode == 401 ||
                response.statusCode == 403) {
            await _tokenService.deleteAccessToken();
            return false;
            }

            return false;
        } catch (_) {
            // 네트워크 장애까지 "로그아웃"으로 간주하면
            // 사용자가 인터넷 잠깐 끊긴 것만으로 세션이 날아갈 수 있으니
            // 토큰은 삭제하지 않는다.
            return false;
        }
    }

    Future<void> logout() async {
        await _tokenService.deleteAccessToken();
    }

    Future<bool> isLoggedIn() async {
        return _tokenService.hasAccessToken();
    }
}