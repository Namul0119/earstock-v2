import 'alert_api.dart';

class AlertDataService {
  static Future<List<Map<String, dynamic>>> loadAlertLogs() async {
    final result = await AlertApi.getAlerts();

    return result.reversed.map<Map<String, dynamic>>(
      (item) {
        final alertType =
            item['alertType']?.toString() ?? '';

        final status = alertType == 'LOW'
            ? '🚨 위험'
            : '🎯 목표 도달';

        return {
          'id': item['id'].toString(),
          'stockName': item['stockName'].toString(),
          'status': status,
          'message': item['stockCode'].toString(),
          'createdAt': item['createdAt'] ?? '',
        };
      },
    ).toList();
  }

  static Future<void> clearAlertLogs() async {
    await AlertApi.deleteAlerts();
  }
}