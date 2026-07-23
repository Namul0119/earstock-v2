import 'package:firebase_messaging/firebase_messaging.dart';

import 'fcm_token_api.dart';

class FcmRegistrationService {

  static Future<void> initialize(
    String userId,
  ) async {

    final messaging =
        FirebaseMessaging.instance;

    final permission =
        await messaging.requestPermission();

    print(
      '알림 권한 상태: ${permission.authorizationStatus}',
    );

    final token =
        await messaging.getToken();

    print('FCM Token: $token');

    if (token != null &&
        token.isNotEmpty) {

      try {

        await FcmTokenApi.registerToken(

          userId: userId,

          token: token,

        );

        print(
          'FCM Token 서버 등록 완료',
        );

      } catch (e) {

        print(
          'FCM Token 서버 등록 실패: $e',
        );
      }
    }

    FirebaseMessaging.instance
        .onTokenRefresh
        .listen(

      (newToken) async {

        print(
          'FCM Token 갱신: $newToken',
        );

        try {

          await FcmTokenApi.registerToken(

            userId: userId,

            token: newToken,

          );

          print(
            '갱신된 FCM Token 서버 등록 완료',
          );

        } catch (e) {

          print(
            '갱신된 FCM Token 서버 등록 실패: $e',
          );
        }
      },
    );
  }
}