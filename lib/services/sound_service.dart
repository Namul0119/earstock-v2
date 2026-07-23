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

    await audioPlayer.stop();

    await audioPlayer.setReleaseMode(
      ReleaseMode.loop,
    );

    await audioPlayer.play(
      AssetSource(file),
    );

    soundStopTimer?.cancel();

    final timer = Timer(
      const Duration(seconds: 5),
      () async {

        await audioPlayer.stop();

        await audioPlayer.setReleaseMode(
          ReleaseMode.release,
        );
      },
    );

    return timer;
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