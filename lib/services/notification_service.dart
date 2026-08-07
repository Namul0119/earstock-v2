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
        data['alertType']?.toString() ?? 'NOTICE';

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
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.reload();

    final bool pushEnabled =
        prefs.getBool(pushEnabledKey) ?? true;

    final bool soundEnabled =
        prefs.getBool(soundEnabledKey) ?? true;

    final bool vibrationEnabled =
        prefs.getBool(vibrationEnabledKey) ?? true;

    if (!pushEnabled) {
      _log(
        '푸시 알림 OFF: 알림을 표시하지 않음',
      );
      return;
    }

    final String normalizedAlertType =
        alertType.toUpperCase();

    final bool isLow =
        normalizedAlertType == 'LOW';

    final bool isHigh =
        normalizedAlertType == 'HIGH';

    final bool isNotice =
        normalizedAlertType == 'NOTICE';

    /*
     * NOTICE는 일반 공지이므로
     * 위험/목표 알림음을 사용하지 않는다.
     */
    final bool shouldPlaySound =
        soundEnabled && !isNotice;

    String? soundName;

    if (isLow) {
      final String selectedSoundPath =
          prefs.getString(warningSoundKey) ??
              'sounds/warning_01.mp3';

      soundName = selectedSoundPath
          .replaceFirst('sounds/', '')
          .replaceFirst('.mp3', '');
    } else if (isHigh) {
      final String selectedSoundPath =
          prefs.getString(successSoundKey) ??
              'sounds/success_01.mp3';

      soundName = selectedSoundPath
          .replaceFirst('sounds/', '')
          .replaceFirst('.mp3', '');
    }

    final String soundState =
        shouldPlaySound
            ? 'sound_on'
            : 'sound_off';

    final String vibrationState =
        vibrationEnabled
            ? 'vibration_on'
            : 'vibration_off';

    final String channelId;

    final String channelName;

    final String channelDescription;

    if (isLow) {
      channelId =
          'earstock_${soundName}_${soundState}_${vibrationState}_low_channel';

      channelName =
          'EarStock 위험 알림 - $soundName - $soundState - $vibrationState';

      channelDescription =
          'EarStock 하락 기준가 도달 알림';
    } else if (isHigh) {
      channelId =
          'earstock_${soundName}_${soundState}_${vibrationState}_high_channel';

      channelName =
          'EarStock 목표 알림 - $soundName - $soundState - $vibrationState';

      channelDescription =
          'EarStock 상승 기준가 도달 알림';
    } else {
      channelId =
          'earstock_notice_${vibrationState}_channel';

      channelName =
          'EarStock 일반 공지 - $vibrationState';

      channelDescription =
          'EarStock 관리자 일반 공지';
    }

    _log('알림 표시 시작');
    _log('title: $title');
    _log('alertType: $normalizedAlertType');
    _log('soundName: ${soundName ?? "없음"}');
    _log('channelId: $channelId');
    _log('pushEnabled: $pushEnabled');
    _log('soundEnabled: $soundEnabled');
    _log('shouldPlaySound: $shouldPlaySound');
    _log(
      'vibrationEnabled: $vibrationEnabled',
    );

    final androidDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          channelDescription,

      importance: isNotice
          ? Importance.high
          : Importance.max,

      priority: Priority.high,

      playSound: shouldPlaySound,

      sound: shouldPlaySound &&
              soundName != null
          ? RawResourceAndroidNotificationSound(
              soundName,
            )
          : null,

      enableVibration:
          vibrationEnabled,

      category: isNotice
          ? AndroidNotificationCategory.message
          : AndroidNotificationCategory.alarm,

      visibility:
          NotificationVisibility.public,
    );

    final notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    final int notificationId =
        DateTime.now()
            .millisecondsSinceEpoch
            .remainder(100000);

    try {
      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
      );

      _log('알림 표시 완료');
    } catch (e) {
      _log(
        '알림 표시 실패: $e',
      );
    }
  }
}