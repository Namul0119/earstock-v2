import 'alert_api.dart';

class AlertDataService {
  static Future<List<Map<String, dynamic>>> loadAlertLogs(
    String userId,
  ) async {
    final result = await AlertApi.getAlerts(
      userId,
    );

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

  static Future<void> clearAlertLogs(
    String userId,
  ) async {
    await AlertApi.deleteAlerts(
      userId,
    );
  }
}