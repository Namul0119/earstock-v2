import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'fcm_token_api.dart';

class FcmRegistrationService {
  static bool _initialized = false;

  static void reset() {
    _initialized = false;

    debugPrint(
      'FCM Registration 상태 초기화 완료',
    );
  }

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final messaging =
        FirebaseMessaging.instance;

    try {
      final permission =
          await messaging.requestPermission();

      debugPrint(
        '알림 권한 상태: '
        '${permission.authorizationStatus}',
      );

      final token =
          await messaging.getToken();

      debugPrint('FCM Token 발급 완료');

      if (token != null &&
          token.isNotEmpty) {
        try {
          await FcmTokenApi.registerToken(
            token: token,
          );

          debugPrint(
            'FCM Token 서버 등록 완료',
          );
        } catch (e) {
          debugPrint(
            'FCM Token 서버 등록 실패: $e',
          );
        }
      }

      messaging.onTokenRefresh.listen(
        (newToken) async {
          debugPrint(
            'FCM Token 갱신',
          );

          try {
            await FcmTokenApi.registerToken(
              token: newToken,
            );

            debugPrint(
              '갱신된 FCM Token 서버 등록 완료',
            );
          } catch (e) {
            debugPrint(
              '갱신된 FCM Token 서버 등록 실패: $e',
            );
          }
        },
        onError: (error) {
          debugPrint(
            'FCM Token 갱신 감지 오류: $error',
          );
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint(
        'FCM Registration 초기화 실패: $e',
      );

      rethrow;
    }
  }
}