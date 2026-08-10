import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_service.dart';
import 'token_service.dart';

import '../exceptions/api_exceptions.dart';

class WatchApi {
  static const String baseUrl = ApiService.baseUrl;

  static final TokenService _tokenService = TokenService();

  static Future<Map<String, String>> _getHeaders({
    bool includeJsonContentType = false,
  }) async {
    final accessToken =
        await _tokenService.getAccessToken();

    if (accessToken == null ||
        accessToken.isEmpty) {
      throw UnauthorizedException(
        '로그인이 필요합니다.',
      );
    }

    return {
      'Authorization': 'Bearer $accessToken',
      if (includeJsonContentType)
        'Content-Type':
            'application/json; charset=UTF-8',
    };
  }

  static Future<List<dynamic>> getWatchList() async {
    final uri = Uri.parse(
      '$baseUrl/api/watch',
    );

    final headers = await _getHeaders();

    print('감시목록 요청 주소: $uri');

    final response = await http.get(
      uri,
      headers: headers,
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      '감시목록 상태 코드: ${response.statusCode}',
    );
    print('감시목록 응답: $responseText');

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(responseText);

      if (decoded is List) {
        return decoded;
      }

      throw Exception(
        '감시목록 응답이 List 형식이 아닙니다.',
      );
    }

    _handleUnauthorized(
      response.statusCode,
    );

    throw Exception(
      '감시목록 조회 실패: '
      '${response.statusCode} $responseText',
    );
  }

  static Future<void> addWatch({
    required String stockCode,
    required int lowPrice,
    required int highPrice,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/watch',
    );

    final headers = await _getHeaders(
      includeJsonContentType: true,
    );

    final requestBody = {
      'stockCode': stockCode,
      'lowPrice': lowPrice,
      'highPrice': highPrice,
    };

    print('감시 종목 등록 주소: $uri');
    print('감시 종목 등록 데이터: $requestBody');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(requestBody),
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      '종목 등록 상태 코드: ${response.statusCode}',
    );
    print('종목 등록 응답: $responseText');

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
          : '감시 종목 등록 실패',
    );
  }

  static Future<void> deleteWatch(
    String id,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/watch/$id',
    );

    final headers = await _getHeaders();

    final response = await http.delete(
      uri,
      headers: headers,
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      '종목 삭제 상태 코드: ${response.statusCode}',
    );
    print('종목 삭제 응답: $responseText');

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
          : '감시 종목 삭제 실패',
    );
  }

  static Future<void> updateWatch({
    required String id,
    required int lowPrice,
    required int highPrice,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/watch/$id',
    );

    final headers = await _getHeaders(
      includeJsonContentType: true,
    );

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode({
        'lowPrice': lowPrice,
        'highPrice': highPrice,
      }),
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print(
      '종목 수정 상태 코드: ${response.statusCode}',
    );
    print('종목 수정 응답: $responseText');

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
          : '감시 가격 수정 실패',
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