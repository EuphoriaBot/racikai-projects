import 'package:flutter/material.dart';

import '../features/recipe/data/models/catalog_recipe.dart';
import '../services/local_storage_service.dart';

class MealPlannerController extends ChangeNotifier {
  MealPlannerController._();

  static final MealPlannerController instance = MealPlannerController._();

  final Map<String, CatalogRecipe> _mealPlan = {};

  final List<String> days = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  bool get hasMeals => _mealPlan.isNotEmpty;

  Future<void> loadFromStorage() async {
    _mealPlan
      ..clear()
      ..addAll(LocalStorageService.mealPlan);

    notifyListeners();
  }

  CatalogRecipe? recipeForDay(String day) {
    return _mealPlan[day];
  }

  String? recipeIdForDay(String day) {
    return _mealPlan[day]?.id;
  }

  void setRecipeForDay(String day, CatalogRecipe recipe) {
    _mealPlan[day] = recipe;

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
