import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_service.dart';

class StockApi {
  static const String baseUrl =
    "${ApiService.baseUrl}/api/stocks";

  static Future<List<Map<String, dynamic>>> searchStocks(
    String keyword,
  ) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      '$baseUrl/search',
    ).replace(
      queryParameters: {
        'keyword': trimmedKeyword,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        '종목 검색 실패: ${response.statusCode}',
      );
    }

    final List<dynamic> decoded =
        jsonDecode(utf8.decode(response.bodyBytes));

    return decoded
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }
}