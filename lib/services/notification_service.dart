import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String soundEnabledKey = 'soundEnabled';
  static const String vibrationEnabledKey = 'vibrationEnabled';
  static const String pushEnabledKey = 'pushEnabled';
  static const String warningSoundKey = 'selectedWarningSound';
  static const String successSoundKey = 'selectedSuccessSound';

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      initializationSettings,
    );

    _log('NotificationService 초기화 완료');
  }

  static Future<void> showFromFcmData(
    Map<String, dynamic> data,
  ) async {
    final String title =
        data['title']?.toString() ?? 'EarStock';

    final String body =
        data['body']?.toString() ?? '';

    final String alertType =
        data['alertType']?.toString() ?? 'HIGH';

    await show(
      title: title,
      body: body,
      alertType: alertType,
    );
  }

  static Future<void> show({
    required String title,
    required String body,
    required String alertType,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.reload();

    final bool pushEnabled =
        prefs.getBool(pushEnabledKey) ?? true;

    final bool soundEnabled =
        prefs.getBool(soundEnabledKey) ?? true;

    final bool vibrationEnabled =
        prefs.getBool(vibrationEnabledKey) ?? true;

    if (!pushEnabled) {
      _log('푸시 알림 OFF: 알림을 표시하지 않음');
      return;
    }

    final bool isLow = alertType.toUpperCase() == 'LOW';

    final String selectedSoundPath = isLow
        ? prefs.getString(warningSoundKey) ??
            'sounds/warning_01.mp3'
        : prefs.getString(successSoundKey) ??
            'sounds/success_01.mp3';

    // sounds/warning_03.mp3 → warning_03
    final String soundName = selectedSoundPath
        .replaceFirst('sounds/', '')
        .replaceFirst('.mp3', '');

    /*
     * Android 8 이상에서는 알림음이 채널에 저장된다.
     * 음원마다 채널 ID를 다르게 사용한다.
     */
    final String soundState =
    soundEnabled ? 'sound_on' : 'sound_off';

    final String vibrationState =
        vibrationEnabled ? 'vibration_on' : 'vibration_off';

    final String channelId =
        'earstock_${soundName}_${soundState}_${vibrationState}_channel';

    final String channelName = isLow
        ? 'EarStock 위험 알림 - $soundName - $soundState - $vibrationState'
        : 'EarStock 목표 알림 - $soundName - $soundState - $vibrationState';

    _log('알림 표시 시작');
    _log('title: $title');
    _log('alertType: $alertType');
    _log('soundName: $soundName');
    _log('channelId: $channelId');
    _log('soundEnabled: $soundEnabled');
    _log('vibrationEnabled: $vibrationEnabled');

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'EarStock 사용자 선택 알림음',
      importance: Importance.max,
      priority: Priority.high,

      playSound: soundEnabled,

      sound: soundEnabled
          ? RawResourceAndroidNotificationSound(
              soundName,
            )
          : null,

      enableVibration: vibrationEnabled,

      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(
              100000,
            );

    try {
      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );

      _log('알림 표시 완료');
    } catch (e) {
      _log('알림 표시 실패: $e');
    }
  }
}