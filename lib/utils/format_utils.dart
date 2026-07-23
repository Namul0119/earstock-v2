String formatPrice(dynamic value) {
  final number = int.tryParse(value.toString());

  if (number == null) {
    return value.toString();
  }

  return number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

String formatTime(String? dateTimeText) {
  if (dateTimeText == null || dateTimeText.isEmpty) {
    return '아직 없음';
  }

  final dateTime = DateTime.tryParse(dateTimeText);

  if (dateTime == null) {
    return '아직 없음';
  }

  final hour =
      dateTime.hour.toString().padLeft(2, '0');

  final minute =
      dateTime.minute.toString().padLeft(2, '0');

  final second =
      dateTime.second.toString().padLeft(2, '0');

  return '$hour:$minute:$second';
}

String formatRelativeTime(
  String? dateTimeText,
) {
  if (dateTimeText == null ||
      dateTimeText.isEmpty) {
    return '아직 없음';
  }

  final dateTime =
      DateTime.tryParse(dateTimeText);

  if (dateTime == null) {
    return '아직 없음';
  }

  final difference =
      DateTime.now().difference(dateTime);

  if (difference.inSeconds < 10) {
    return '방금 전';
  }

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}초 전';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  }

  return formatTime(dateTimeText);
}