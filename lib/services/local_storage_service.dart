import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class LocalStorageService {
  static late SharedPreferences _preferences;

  static const String _premiumKey = 'is_premium';
  static const String _subscriptionPlanKey = 'subscription_plan';

  static const String _favoriteIdsKey = 'favorite_ids';

  static const String _aiUsageKey = 'ai_usage';

  static const String _lastUsageDateKey = 'last_usage_date';

  static const String _mealPlanKey = 'meal_plan';

  static const String _themeModeKey = 'theme_mode';

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static bool get isPremium {
    return _preferences.getBool(_premiumKey) ?? false;
  }

  static String? get subscriptionPlan {
    return _preferences.getString(_subscriptionPlanKey);
  }

  static Future<void> saveSubscription({
    required bool isPremium,
    String? plan,
  }) async {
    await _preferences.setBool(_premiumKey, isPremium);

    if (plan == null) {
      await _preferences.remove(_subscriptionPlanKey);
    } else {
      await _preferences.setString(_subscriptionPlanKey, plan);
    }
  }

  static List<int> get favoriteIds {
    final storedIds = _preferences.getStringList(_favoriteIdsKey) ?? [];

    return storedIds.map(int.tryParse).whereType<int>().toList();
  }

  static Future<void> saveFavoriteIds(Set<int> favoriteIds) async {
    final values = favoriteIds.map((id) => id.toString()).toList();

    await _preferences.setStringList(_favoriteIdsKey, values);
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

  static Map<String, int> get mealPlan {
    final storedData = _preferences.getString(_mealPlanKey);

    if (storedData == null) {
      return {};
    }

    try {
      final decoded = jsonDecode(storedData) as Map<String, dynamic>;

      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveMealPlan(Map<String, int> mealPlan) async {
    await _preferences.setString(_mealPlanKey, jsonEncode(mealPlan));
  }

  static Future<void> clearMealPlan() async {
    await _preferences.remove(_mealPlanKey);
  }

  static String? get themeMode {
    return _preferences.getString(_themeModeKey);
  }

  static Future<void> saveThemeMode(String mode) async {
    await _preferences.setString(_themeModeKey, mode);
  }
}
