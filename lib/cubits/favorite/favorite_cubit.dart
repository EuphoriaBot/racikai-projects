import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controllers/subscription_controller.dart';
import '../../services/local_storage_service.dart';
import 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(const FavoriteState());

  static const int freeFavoriteLimit = 10;

  void loadFromStorage() {
    final savedFavorites = LocalStorageService.favoriteIds;

    emit(FavoriteState(favoriteIds: Set<String>.unmodifiable(savedFavorites)));
  }

  void toggleFavorite(Object recipeId) {
    final favoriteKey = favoriteKeyFor(recipeId);

    final updatedIds = Set<String>.from(state.favoriteIds);

    if (updatedIds.contains(favoriteKey)) {
      updatedIds.remove(favoriteKey);

      LocalStorageService.saveFavoriteIds(updatedIds);

      emit(
        FavoriteState(
          favoriteIds: Set<String>.unmodifiable(updatedIds),
          action: FavoriteAction.removed,
          actionId: state.actionId + 1,
        ),
      );

      return;
    }

    final isPremium = SubscriptionController.instance.isPremium;

    if (!isPremium && updatedIds.length >= freeFavoriteLimit) {
      emit(
        state.copyWith(
          action: FavoriteAction.limitReached,
          actionId: state.actionId + 1,
        ),
      );

      return;
    }

    updatedIds.add(favoriteKey);

    LocalStorageService.saveFavoriteIds(updatedIds);

    emit(
      FavoriteState(
        favoriteIds: Set<String>.unmodifiable(updatedIds),
        action: FavoriteAction.added,
        actionId: state.actionId + 1,
      ),
    );
  }
}
