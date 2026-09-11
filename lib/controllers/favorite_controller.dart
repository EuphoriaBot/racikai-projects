import 'package:flutter/material.dart';

import '../data/dummy_recipes.dart';
import '../models/recipe.dart';

class FavoriteController extends ChangeNotifier {
  FavoriteController._();

  static final FavoriteController instance = FavoriteController._();

  final Set<int> _favoriteIds = {};

  bool isFavorite(int recipeId) {
    return _favoriteIds.contains(recipeId);
  }

  void toggleFavorite(int recipeId) {
    if (_favoriteIds.contains(recipeId)) {
      _favoriteIds.remove(recipeId);
    } else {
      _favoriteIds.add(recipeId);
    }

    notifyListeners();
  }

  List<Recipe> get favoriteRecipes {
    return dummyRecipes
        .where((recipe) => _favoriteIds.contains(recipe.id))
        .toList();
  }

  int get favoriteCount => _favoriteIds.length;
}
