import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class MealPlannerController extends ChangeNotifier {
  MealPlannerController._();

  static final MealPlannerController instance = MealPlannerController._();

  final Map<String, int> _mealPlan = {};

  final List<String> days = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  Future<void> loadFromStorage() async {
    _mealPlan
      ..clear()
      ..addAll(LocalStorageService.mealPlan);

    notifyListeners();
  }

  int? recipeIdForDay(String day) {
    return _mealPlan[day];
  }

  void setRecipeForDay(String day, int recipeId) {
    _mealPlan[day] = recipeId;

    LocalStorageService.saveMealPlan(_mealPlan);

    notifyListeners();
  }

  void removeRecipeFromDay(String day) {
    _mealPlan.remove(day);

    LocalStorageService.saveMealPlan(_mealPlan);

    notifyListeners();
  }

  void clearPlan() {
    _mealPlan.clear();

    LocalStorageService.clearMealPlan();

    notifyListeners();
  }
}
