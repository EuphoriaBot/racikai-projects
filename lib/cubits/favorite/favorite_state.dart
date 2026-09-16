import 'package:equatable/equatable.dart';

enum FavoriteAction { idle, added, removed, limitReached }

class FavoriteState extends Equatable {
  final Set<int> favoriteIds;
  final FavoriteAction action;
  final int actionId;

  const FavoriteState({
    this.favoriteIds = const <int>{},
    this.action = FavoriteAction.idle,
    this.actionId = 0,
  });

  bool isFavorite(int recipeId) {
    return favoriteIds.contains(recipeId);
  }

  int get favoriteCount {
    return favoriteIds.length;
  }

  FavoriteState copyWith({
    Set<int>? favoriteIds,
    FavoriteAction? action,
    int? actionId,
  }) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      action: action ?? this.action,
      actionId: actionId ?? this.actionId,
    );
  }

  @override
  List<Object> get props => [favoriteIds, action, actionId];
}
