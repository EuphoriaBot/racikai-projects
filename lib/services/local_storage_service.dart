import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../features/favorite/data/models/saved_recipe.dart';
import '../features/recipe/data/models/catalog_recipe.dart';

class LocalStorageService {
  static late SharedPreferences _preferences;

  static const String _favoriteIdsKey = 'favorite_ids';

  static const String _savedBackendRecipesKey = 'saved_backend_recipes_v1';

  static const String _aiUsageKey = 'ai_usage';

  static const String _lastUsageDateKey = 'last_usage_date';

  static const String _legacyMealPlanKey = 'meal_plan';

  static const String _mealPlanKey = 'meal_plan_backend_v1';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    if (_preferences.containsKey(_legacyMealPlanKey)) {
      await _preferences.remove(_legacyMealPlanKey);
    }
  }

  static List<String> get favoriteIds {
    final storedIds = _preferences.getStringList(_favoriteIdsKey) ?? [];

    return storedIds.map((id) => id.trim()).where((id) => id.isNotEmpty).map((
      id,
    ) {
      if (id.startsWith('local:') || id.startsWith('backend:')) {
        return id;
      }

      return 'local:$id';
    }).toList();
  }

  static Future<void> saveFavoriteIds(Set<String> favoriteIds) async {
    final values = favoriteIds.toList()..sort();

    await _preferences.setStringList(_favoriteIdsKey, values);
  }

  static List<SavedRecipe> get savedBackendRecipes {
    final storedData = _preferences.getString(_savedBackendRecipesKey);

    if (storedData == null || storedData.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is! List) {
        return [];
      }

      final recipes = <SavedRecipe>[];

      for (final item in decoded) {
        if (item is Map) {
          recipes.add(SavedRecipe.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      return recipes;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveBackendRecipes(List<SavedRecipe> recipes) async {
    final encoded = jsonEncode(
      recipes.map((recipe) => recipe.toJson()).toList(),
    );

    await _preferences.setString(_savedBackendRecipesKey, encoded);
  }

  static int get aiUsage {
    return _preferences.getInt(_aiUsageKey) ?? 0;
  }

  static DateTime? get lastUsageDate {
    final storedDate = _preferences.getString(_lastUsageDateKey);

    if (storedDate == null) {
      return null;
    }

    return DateTime.tryParse(storedDate);
  }

  static Future<void> saveAiUsage({
    required int usage,
    required DateTime date,
  }) async {
    await _preferences.setInt(_aiUsageKey, usage);

    await _preferences.setString(_lastUsageDateKey, date.toIso8601String());
  }

  static Map<String, CatalogRecipe> get mealPlan {
    final storedData = _preferences.getString(_mealPlanKey);

    if (storedData == null || storedData.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is! Map) {
        return {};
      }

      final result = <String, CatalogRecipe>{};

      for (final entry in decoded.entries) {
        final value = entry.value;

        if (value is! Map) {
          continue;
        }

        result[entry.key.toString()] = CatalogRecipe.fromJson(
          Map<String, dynamic>.from(value),
        );
      }

      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveMealPlan(Map<String, CatalogRecipe> mealPlan) async {
    final encodedPlan = <String, dynamic>{};

    for (final entry in mealPlan.entries) {
      final recipe = entry.value;

      encodedPlan[entry.key] = {
        'id': recipe.id,
        'title': recipe.title,
        'ingredients': recipe.ingredients,
        'ingredient_list': recipe.ingredientList,
        'instructions': recipe.instructions,
        'image_name': recipe.imageName,
        'image_url': recipe.imageUrl,
        'ingredient_count': recipe.ingredientCount,
      };
    }

    await _preferences.setString(_mealPlanKey, jsonEncode(encodedPlan));
  }

  static Future<void> clearMealPlan() async {
    await _preferences.remove(_mealPlanKey);

    await _preferences.remove(_legacyMealPlanKey);
  }
}
