extension CookingTimeExtension on int {
  String get toClockFormat {
    final minutes = this ~/ 60;
    final seconds = this % 60;

    final minuteText = minutes.toString().padLeft(2, '0');

    final secondText = seconds.toString().padLeft(2, '0');

    return '$minuteText:$secondText';
  }
}
