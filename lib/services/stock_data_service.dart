import 'watch_api.dart';

class StockDataService {
  static Future<List<Map<String, dynamic>>> loadStocks() async {

    final result =
        await WatchApi.getWatchList();

    final now = DateTime.now();

    return result.map<Map<String, dynamic>>(
      (item) {

        return {

          'id': item['id'].toString(),

          'name':
              item['stockName']?.toString().trim().isNotEmpty == true
                  ? item['stockName'].toString()
                  : item['stockCode'].toString(),

          'stockCode':
              item['stockCode'].toString(),

          'basePrice':
              item['basePrice']?.toString() ?? '',

          'low':
              item['lowPrice'].toString(),

          'high':
              item['highPrice'].toString(),

          'currentPrice':
              item['currentPrice'] == null
                  ? '시세 확인중'
                  : item['currentPrice'].toString(),

          'changeRate':
              item['changeRate'] == null
                  ? 0.0
                  : double.tryParse(
                          item['changeRate'].toString(),
                        ) ??
                      0.0,

          'changePrice':
              item['changePrice'] ?? 0,

          'volume':
              item['volume'] ?? 0,

          'status':
              item['lastAlertType'] == 'LOW'
                  ? '🚨 위험'
                  : item['lastAlertType'] == 'HIGH'
                      ? '🎯 목표 도달'
                      : '감시중',

          'updatedAt':
              now.toIso8601String(),

          'lastAlertStatus':
              item['lastAlertType'] ?? '',
        };
      },
    ).toList();
  }
}