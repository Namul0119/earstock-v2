import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationSettingCard extends StatelessWidget {

    final bool isSettingOpen;
    final Color panelColor;
    final bool soundEnabled;
    final Color accentColor;
    final ValueChanged<bool> onSoundChanged;
    final bool vibrationEnabled;
    final ValueChanged<bool> onVibrationChanged;
    final bool pushEnabled;
    final ValueChanged<bool> onPushChanged;

    final String warningSoundName;
    final VoidCallback onWarningSoundTap;
    final String successSoundName;
    final VoidCallback onSuccessSoundTap;

    final VoidCallback onWarningTestTap;
    final VoidCallback onSuccessTestTap;

    const NotificationSettingCard({
        super.key,
        required this.isSettingOpen,
        required this.panelColor,
        required this.soundEnabled,
        required this.accentColor,
        required this.onSoundChanged,
        required this.vibrationEnabled,
        required this.onVibrationChanged,
        required this.pushEnabled,
        required this.onPushChanged,
        required this.warningSoundName,
        required this.onWarningSoundTap,
        required this.successSoundName,
        required this.onSuccessSoundTap,
        required this.onWarningTestTap,
        required this.onSuccessTestTap,
    });

    @override
    Widget build(BuildContext context) {
        if (!isSettingOpen) {
            return const SizedBox.shrink();
        }

        return Card(
            color: panelColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
                children: [
                    // 소리 알림 스위치
                    SizedBox(
                        height: 42,
                        child: ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: const Text(
                                '소리 알림',
                                style: TextStyle(fontSize: 14),
                            ),
                            trailing: Transform.scale(
                                scale: 0.72,
                                child: CupertinoSwitch(
                                    value: soundEnabled,
                                    activeColor: accentColor,
                                    onChanged: onSoundChanged,
                                ),
                            ),
                        ),
                    ),

                    // 소리가 켜졌을 때만 알림음 선택 메뉴 표시
                    if (soundEnabled) ...[
                        const Divider(
                            color: Colors.white12,
                            height: 1,
                        ),

                        ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xffFF5C7A),
                                size: 20,
                            ),
                            title: const Text(
                                '위험 알림음',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                            subtitle: Text(
                                warningSoundName,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                ),
                            ),
                            trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                            ),
                            onTap: onWarningSoundTap,
                        ),

                        ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: const Icon(
                                Icons.flag_rounded,
                                color: Color(0xff00F5A0),
                            size: 20,
                            ),
                            title: const Text(
                                '목표 알림음',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                            subtitle: Text(
                                successSoundName,
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                ),
                            ),
                            trailing: const Icon(
                                Icons.chevron_right,
                                color: Colors.white54,
                            ),
                            onTap: onSuccessSoundTap,
                        ),
                    ],

                    // 여기부터는 소리 설정과 독립적
                    const Divider(
                        color: Colors.white12,
                        height: 1,
                    ),

                    // 진동 알림 스위치
                    SizedBox(
                        height: 42,
                        child: ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: const Text(
                                '진동 알림',
                                style: TextStyle(fontSize: 14),
                            ),
                            trailing: Transform.scale(
                                scale: 0.72,
                                child: CupertinoSwitch(
                                    value: vibrationEnabled,
                                    activeColor: accentColor,
                                    onChanged: onVibrationChanged,
                                ),
                            ),
                        ),
                    ),

                    // 푸시 알림 스위치
                    SizedBox(
                        height: 42,
                        child: ListTile(
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: const Text(
                                '푸시 알림',
                                style: TextStyle(fontSize: 14),
                            ),
                            trailing: Transform.scale(
                                scale: 0.72,
                                child: CupertinoSwitch(
                                    value: pushEnabled,
                                    activeColor: accentColor,
                                    onChanged: onPushChanged,
                                ),
                            ),
                        ),
                    ),

                    const Divider(
                        color: Colors.white12,
                        height: 1,
                    ),

                    Padding(
                        padding: const EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            14,
                        ),
                        child: Row(
                            children: [
                                Expanded(
                                    child: SizedBox(
                                        height: 42,
                                        child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xffFF5C7A),
                                                side: BorderSide(
                                                color: const Color(0xffFF5C7A)
                                                    .withOpacity(0.45),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(14),
                                                ),
                                            ),
                                            onPressed: onWarningTestTap,
                                            icon: const Icon(
                                                Icons.volume_up_rounded,
                                                size: 18,
                                            ),
                                            label: const Text(
                                                '위험 테스트',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                    child: SizedBox(
                                        height: 42,
                                        child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                                foregroundColor:
                                                    const Color(0xff00F5A0),
                                                side: BorderSide(
                                                    color: const Color(0xff00F5A0)
                                                        .withOpacity(0.45),
                                                ),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(14),
                                                ),
                                            ),
                                            onPressed: onSuccessTestTap,
                                            icon: const Icon(
                                                Icons.flag_rounded,
                                                size: 18,
                                            ),
                                            label: const Text(
                                                '목표 테스트',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                ),
                                            ),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ],
            ),
        );
    }
}