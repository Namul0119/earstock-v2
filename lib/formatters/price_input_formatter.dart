import 'package:flutter/services.dart';

class PriceInputFormatter extends TextInputFormatter {
  const PriceInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
      );
    }

    final number = int.tryParse(digits);

    if (number == null) {
      return oldValue;
    }

    final formatted = formatPriceInput(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

String formatPriceInput(dynamic value) {
  if (value == null) {
    return '';
  }

  final digits = value
      .toString()
      .replaceAll(',', '')
      .trim();

  if (digits.isEmpty) {
    return '';
  }

  final number = int.tryParse(digits);

  if (number == null) {
    return '';
  }

  return number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}