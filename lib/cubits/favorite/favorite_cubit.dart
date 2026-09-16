import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controllers/subscription_controller.dart';
import '../../data/dummy_recipes.dart';
import '../../models/recipe.dart';
import '../../services/local_storage_service.dart';
import 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(const FavoriteState());

  static const int freeFavoriteLimit = 4;

  void loadFromStorage() {
    final savedFavorites = LocalStorageService.favoriteIds;

    emit(FavoriteState(favoriteIds: Set<int>.unmodifiable(savedFavorites)));
  }

  void toggleFavorite(int recipeId) {
    final updatedIds = Set<int>.from(state.favoriteIds);

    // Jika sudah favorit, hapus.
    if (updatedIds.contains(recipeId)) {
      updatedIds.remove(recipeId);

      LocalStorageService.saveFavoriteIds(updatedIds);

      emit(
        FavoriteState(
          favoriteIds: Set<int>.unmodifiable(updatedIds),
          action: FavoriteAction.removed,
          actionId: state.actionId + 1,
        ),
      );

      return;
    }

    // Cek apakah user Premium.
    final isPremium = SubscriptionController.instance.isPremium;

    // Free user mempunyai batas favorit.
    if (!isPremium && updatedIds.length >= freeFavoriteLimit) {
      emit(
        state.copyWith(
          action: FavoriteAction.limitReached,
          actionId: state.actionId + 1,
        ),
      );

      return;
    }

    // Tambahkan favorit.
    updatedIds.add(recipeId);

    LocalStorageService.saveFavoriteIds(updatedIds);

    emit(
      FavoriteState(
        favoriteIds: Set<int>.unmodifiable(updatedIds),
        action: FavoriteAction.added,
        actionId: state.actionId + 1,
      ),
    );
  }

  List<Recipe> get favoriteRecipes {
    return dummyRecipes.where((recipe) {
      return state.favoriteIds.contains(recipe.id);
    }).toList();
  }
}
