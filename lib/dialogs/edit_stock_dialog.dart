import 'package:flutter/material.dart';

class EditStockDialogResult {
  final String lowPriceText;
  final String highPriceText;

  const EditStockDialogResult({
    required this.lowPriceText,
    required this.highPriceText,
  });
}

Future<EditStockDialogResult?> showEditStockDialog({
    required BuildContext context,
    required Map<String, dynamic> stock,
}) async {
    final lowController = TextEditingController(
        text: stock['low']?.toString() ?? '',
    );

    final highController = TextEditingController(
        text: stock['high']?.toString() ?? '',
    );

    return await showDialog<EditStockDialogResult>(
        context: context,
        builder: (dialogContext) {
        return AlertDialog(
            title: Text(
            '${stock['name']} 수정',
            ),
            content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                TextField(
                controller: lowController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '하락 기준 가격',
                ),
                ),

                const SizedBox(height: 12),

                TextField(
                controller: highController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: '상승 기준 가격',
                ),
                ),
            ],
            ),
            actions: [
            TextButton(
                onPressed: () {
                Navigator.pop(
                    dialogContext,
                );
                },
                child: const Text('취소'),
            ),

            ElevatedButton(
                onPressed: () {
                Navigator.pop(
                    dialogContext,
                    EditStockDialogResult(
                    lowPriceText:
                        lowController.text,
                    highPriceText:
                        highController.text,
                    ),
                );
                },
                child: const Text('저장'),
            ),
            ],
        );
        },
    );
}