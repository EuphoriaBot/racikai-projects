import 'package:flutter/material.dart';

import '../data/dummy_recipes.dart';
import '../models/recipe.dart';
import 'subscription_controller.dart';
import '../services/local_storage_service.dart';

enum FavoriteResult { added, removed, limitReached }

class FavoriteController extends ChangeNotifier {
  FavoriteController._();

  static final FavoriteController instance = FavoriteController._();

  static const int freeFavoriteLimit = 4;

  final Set<int> _favoriteIds = {};

  bool isFavorite(int recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  Future<void> loadFromStorage() async {
    final savedFavorites = LocalStorageService.favoriteIds;

    _favoriteIds
      ..clear()
      ..addAll(savedFavorites);

    notifyListeners();
  }

  FavoriteResult toggleFavorite(int recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);

      LocalStorageService.saveFavoriteIds(_favoriteIds);

      notifyListeners();

      return FavoriteResult.removed;
    }

    final isPremium = SubscriptionController.instance.isPremium;

    if (!isPremium && _favoriteIds.length >= freeFavoriteLimit) {
      return FavoriteResult.limitReached;
    }

    _favoriteIds.add(recipeId);

    LocalStorageService.saveFavoriteIds(_favoriteIds);

    notifyListeners();

    return FavoriteResult.added;
  }

  List<Recipe> get favoriteRecipes {
    return dummyRecipes
        .where((recipe) => _favoriteIds.contains(recipe.id))
        .toList();
  }

  int get favoriteCount => _favoriteIds.length;
}
