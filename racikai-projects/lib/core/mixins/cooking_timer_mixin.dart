mixin CookingTimerMixin {
  Stream<int> cookingTimer(int startFrom) async* {
    var seconds = startFrom;

    while (true) {
      await Future.delayed(const Duration(seconds: 1));

      seconds++;

      yield seconds;
    }
  }
}
