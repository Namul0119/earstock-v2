import 'package:flutter/services.dart';

class VibrationService {
  static Future<void> play({
    required String status,
    required bool vibrationEnabled,
  }) async {
    if (!vibrationEnabled) {
      return;
    }

    if (status == 'LOW') {
      await HapticFeedback.heavyImpact();
    } else if (status == 'HIGH') {
      await HapticFeedback.lightImpact();
    }
  }
}