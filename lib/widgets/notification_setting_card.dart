import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationSettingCard extends StatelessWidget {
  final bool isSettingOpen;
  final Color panelColor;

  final bool pushEnabled;
  final ValueChanged<bool> onPushChanged;

  final bool soundEnabled;
  final Color accentColor;
  final ValueChanged<bool> onSoundChanged;

  final bool vibrationEnabled;
  final ValueChanged<bool> onVibrationChanged;

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
    required this.pushEnabled,
    required this.onPushChanged,
    required this.soundEnabled,
    required this.accentColor,
    required this.onSoundChanged,
    required this.vibrationEnabled,
    required this.onVibrationChanged,
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

    final disabledTextColor = Colors.white38;

    return Card(
      color: panelColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          // 전체 알림 마스터 스위치
          SizedBox(
            height: 64,
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              title: const Text(
                '알림 받기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  pushEnabled
                      ? '소리와 진동 방식을 설정할 수 있습니다.'
                      : '모든 EarStock 알림이 꺼져 있습니다.',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    color: Colors.white54,
                  ),
                ),
              ),
              trailing: Transform.scale(
                scale: 0.78,
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
            indent: 16,
            endIndent: 16,
          ),

          // 소리 알림
          SizedBox(
            height: 48,
            child: ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                '소리 알림',
                style: TextStyle(
                  fontSize: 14,
                  color: pushEnabled
                      ? Colors.white
                      : disabledTextColor,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.78,
                child: CupertinoSwitch(
                  value: pushEnabled && soundEnabled,
                  activeColor: accentColor,
                  onChanged: pushEnabled
                      ? onSoundChanged
                      : null,
                ),
              ),
            ),
          ),

          if (pushEnabled && soundEnabled) ...[
            const Divider(
              color: Colors.white12,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),

            // 위험 알림음
            ListTile(
              minVerticalPadding: 10,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xffFF5C7A),
                size: 21,
              ),
              title: const Text(
                '위험 알림음',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  warningSoundName,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
              onTap: onWarningSoundTap,
            ),

            // 목표 알림음
            ListTile(
              minVerticalPadding: 10,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(
                Icons.flag_rounded,
                color: Color(0xff00F5A0),
                size: 21,
              ),
              title: const Text(
                '목표 알림음',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  successSoundName,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              ),
              onTap: onSuccessSoundTap,
            ),
          ],

          const Divider(
            color: Colors.white12,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // 진동 알림
          SizedBox(
            height: 48,
            child: ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                '진동 알림',
                style: TextStyle(
                  fontSize: 14,
                  color: pushEnabled
                      ? Colors.white
                      : disabledTextColor,
                ),
              ),
              trailing: Transform.scale(
                scale: 0.78,
                child: CupertinoSwitch(
                  value: pushEnabled && vibrationEnabled,
                  activeColor: accentColor,
                  onChanged: pushEnabled
                      ? onVibrationChanged
                      : null,
                ),
              ),
            ),
          ),

          const Divider(
            color: Colors.white12,
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // 테스트 버튼
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
                        foregroundColor: pushEnabled
                            ? const Color(0xffFF5C7A)
                            : Colors.white30,
                        side: BorderSide(
                          color: pushEnabled
                              ? const Color(0xffFF5C7A)
                                  .withOpacity(0.45)
                              : Colors.white12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: pushEnabled
                          ? onWarningTestTap
                          : null,
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
                        foregroundColor: pushEnabled
                            ? const Color(0xff00F5A0)
                            : Colors.white30,
                        side: BorderSide(
                          color: pushEnabled
                              ? const Color(0xff00F5A0)
                                  .withOpacity(0.45)
                              : Colors.white12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: pushEnabled
                          ? onSuccessTestTap
                          : null,
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