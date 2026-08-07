import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static Future<Timer?> play({
    required AudioPlayer audioPlayer,
    required bool soundEnabled,
    required String status,
    required String warningSound,
    required String successSound,
    Timer? soundStopTimer,
  }) async {
    if (!soundEnabled) {
      return soundStopTimer;
    }

    final file =
        status == 'LOW'
            ? warningSound
            : successSound;

    // 기존 재생 중인 소리가 있으면 먼저 정지
    soundStopTimer?.cancel();

    await audioPlayer.stop();

    // 반복 재생하지 않고 음원 자체를 1번만 재생
    await audioPlayer.setReleaseMode(
      ReleaseMode.release,
    );

    await audioPlayer.play(
      AssetSource(file),
    );

    // 이제 타이머로 강제 종료하지 않음
    return null;
  }

  static Future<void> stop(
    AudioPlayer audioPlayer,
  ) async {
    await audioPlayer.stop();

    await audioPlayer.setReleaseMode(
      ReleaseMode.release,
    );
  }
}