import 'package:flutter/material.dart';

import 'subscription_controller.dart';
import '../services/local_storage_service.dart';

class UsageController extends ChangeNotifier {
  UsageController._();

  static final UsageController instance = UsageController._();

  static const int freeAiLimit = 5;

  int _aiUsage = 0;
  DateTime _lastUsageDate = DateTime.now();

  int get aiUsage {
    _resetIfNewDay();
    return _aiUsage;
  }

  int get remainingAiQuestions {
    _resetIfNewDay();

    if (SubscriptionController.instance.isPremium) {
      return -1;
    }

    return freeAiLimit - _aiUsage;
  }

  bool get canAskAI {
    _resetIfNewDay();

    if (SubscriptionController.instance.isPremium) {
      return true;
    }

    return _aiUsage < freeAiLimit;
  }

  void recordAiQuestion() {
    _resetIfNewDay();

    if (SubscriptionController.instance.isPremium) {
      return;
    }

    if (_aiUsage < freeAiLimit) {
      _aiUsage++;

      _saveUsage();

      notifyListeners();
    }
  }

  void _resetIfNewDay() {
    final now = DateTime.now();

    final isSameDay =
        now.year == _lastUsageDate.year &&
        now.month == _lastUsageDate.month &&
        now.day == _lastUsageDate.day;

    if (!isSameDay) {
      _aiUsage = 0;
      _lastUsageDate = now;

      _saveUsage();
    }
  }

  void resetUsageForTesting() {
    _aiUsage = 0;
    _lastUsageDate = DateTime.now();

    _saveUsage();

    notifyListeners();
  }

  void _saveUsage() {
    LocalStorageService.saveAiUsage(usage: _aiUsage, date: _lastUsageDate);
  }

  Future<void> loadFromStorage() async {
    _aiUsage = LocalStorageService.aiUsage;

    _lastUsageDate = LocalStorageService.lastUsageDate ?? DateTime.now();

    _resetIfNewDay();

    notifyListeners();
  }
}
