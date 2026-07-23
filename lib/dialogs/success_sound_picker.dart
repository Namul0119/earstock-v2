import 'package:flutter/material.dart';

Future<void> showSuccessSoundPickerSheet({
  required BuildContext context,
  required Color panelColor,
  required Color successColor,
  required String selectedSuccessSound,
  required Future<void> Function(String selectedSound)
      onSoundSelected,
  required Future<void> Function() onPreviewSound,
}) async {
  final sounds = [
    {
      'label': '목표달성음 1',
      'value': 'sounds/success_01.mp3',
    },
    {
      'label': '목표달성음 2',
      'value': 'sounds/success_02.mp3',
    },
    {
      'label': '목표달성음 3',
      'value': 'sounds/success_03.mp3',
    },
    {
      'label': '목표달성음 4',
      'value': 'sounds/success_04.mp3',
    },
    {
      'label': '목표달성음 5',
      'value': 'sounds/success_05.mp3',
    },
  ];

  await showModalBottomSheet(
    context: context,
    backgroundColor: panelColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 18),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '목표 알림음 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ...sounds.map((sound) {
                final isSelected =
                    selectedSuccessSound == sound['value'];

                return ListTile(
                  leading: Icon(
                    Icons.flag_rounded,
                    color: isSelected
                        ? successColor
                        : Colors.white54,
                  ),
                  title: Text(
                    sound['label']!,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: successColor,
                        )
                      : const Icon(
                          Icons.chevron_right,
                          color: Colors.white38,
                        ),
                  onTap: () async {
                    final selectedSound =
                        sound['value']!;

                    await onSoundSelected(
                      selectedSound,
                    );

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }

                    await onPreviewSound();
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}