String getWarningSoundName(
  String selectedWarningSound,
) {
  switch (selectedWarningSound) {
    case 'sounds/warning_02.mp3':
      return '경고음 2';

    case 'sounds/warning_03.mp3':
      return '경고음 3';

    case 'sounds/warning_04.mp3':
      return '경고음 4';

    case 'sounds/warning_05.mp3':
      return '경고음 5';

    default:
      return '경고음 1';
  }
}

String getSuccessSoundName(
  String selectedSuccessSound,
) {
  switch (selectedSuccessSound) {
    case 'sounds/success_02.mp3':
      return '목표달성음 2';

    case 'sounds/success_03.mp3':
      return '목표달성음 3';

    case 'sounds/success_04.mp3':
      return '목표달성음 4';

    case 'sounds/success_05.mp3':
      return '목표달성음 5';

    default:
      return '목표달성음 1';
  }
}