import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_service.dart';
import 'token_service.dart';

class StockApi {
  static const String baseUrl =
      "${ApiService.baseUrl}/api/stocks";

  static final TokenService _tokenService =
      TokenService();

  static Future<List<Map<String, dynamic>>> searchStocks(
    String keyword,
  ) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      return [];
    }

    final token =
        await _tokenService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        '로그인 정보가 없습니다. 다시 로그인해주세요.',
      );
    }

    final uri = Uri.parse(
      '$baseUrl/search',
    ).replace(
      queryParameters: {
        'keyword': trimmedKeyword,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception(
        '로그인이 만료되었습니다. 다시 로그인해주세요.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        '종목 검색 실패: ${response.statusCode}',
      );
    }

    final List<dynamic> decoded =
        jsonDecode(
          utf8.decode(response.bodyBytes),
        );

    return decoded
        .map<Map<String, dynamic>>(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }
}