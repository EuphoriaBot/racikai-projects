import 'package:flutter/material.dart';

enum SubscriptionPlan { monthly, yearly }

class SubscriptionController extends ChangeNotifier {
  SubscriptionController._();

  static final SubscriptionController instance = SubscriptionController._();

  bool _isPremium = false;
  SubscriptionPlan? _selectedPlan;

  bool get isPremium => _isPremium;

  SubscriptionPlan? get selectedPlan => _selectedPlan;

  String get planName {
    if (!_isPremium) {
      return 'RacikAI Free';
    }

    return 'RacikAI Premium';
  }

  String get planPeriod {
    if (!_isPremium || _selectedPlan == null) {
      return 'Free';
    }

    switch (_selectedPlan!) {
      case SubscriptionPlan.monthly:
        return 'Bulanan';
      case SubscriptionPlan.yearly:
        return 'Tahunan';
    }
  }

  void activatePremium(SubscriptionPlan plan) {
    _isPremium = true;
    _selectedPlan = plan;

    notifyListeners();
  }

  void resetToFree() {
    _isPremium = false;
    _selectedPlan = null;

    notifyListeners();
  }
}
