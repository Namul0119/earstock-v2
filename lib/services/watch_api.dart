import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_service.dart';

class WatchApi {
  static const String baseUrl = ApiService.baseUrl;

  static Future<List<dynamic>> getWatchList() async {
    final uri = Uri.parse('$baseUrl/api/watch');

    print('감시목록 요청 주소: $uri');

    final response = await http.get(uri);

    print('감시목록 상태 코드: ${response.statusCode}');
    print(
      '감시목록 응답: '
      '${utf8.decode(response.bodyBytes)}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      if (decoded is List) {
        return decoded;
      }

      throw Exception(
        '감시목록 응답이 List 형식이 아닙니다.',
      );
    }

    throw Exception(
      '감시목록 조회 실패: '
      '${response.statusCode} '
      '${utf8.decode(response.bodyBytes)}',
    );
  }

  static Future<void> addWatch({
    required String userId,
    required String stockCode,
    required int lowPrice,
    required int highPrice,
  }) async {
    final uri = Uri.parse('$baseUrl/api/watch');

    final requestBody = {
      'userId': userId,
      'stockCode': stockCode,
      'lowPrice': lowPrice,
      'highPrice': highPrice,
    };

    print('감시 종목 등록 주소: $uri');
    print('감시 종목 등록 데이터: $requestBody');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    final responseText =
        utf8.decode(response.bodyBytes);

    print('종목 등록 상태 코드: ${response.statusCode}');
    print('종목 등록 응답: $responseText');

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        responseText.isNotEmpty
            ? responseText
            : '감시 종목 등록 실패',
      );
    }
  }

  static Future<void> deleteWatch(String id) async {
    final response = await http.delete(
        Uri.parse("$baseUrl/api/watch/$id"),
    );

    if (response.statusCode != 200) {
        throw Exception("감시 종목 삭제 실패");
    }
  }

  static Future<void> updateWatch({
    required String id,
    required int lowPrice,
    required int highPrice,
    }) async {
    final response = await http.put(
        Uri.parse("$baseUrl/api/watch/$id"),
        headers: {
        "Content-Type": "application/json",
        },
        body: jsonEncode({
        "lowPrice": lowPrice,
        "highPrice": highPrice,
        }),
    );

    if (response.statusCode != 200) {
        throw Exception("감시 가격 수정 실패");
    }
  }
}