import 'package:equatable/equatable.dart';

enum FavoriteAction { idle, added, removed, limitReached }

String favoriteKeyFor(Object recipeId) {
  if (recipeId is int) {
    return 'local:$recipeId';
  }

  final value = recipeId.toString().trim();

  if (value.startsWith('local:') || value.startsWith('backend:')) {
    return value;
  }

  return 'backend:$value';
}

class FavoriteState extends Equatable {
  final Set<String> favoriteIds;
  final FavoriteAction action;
  final int actionId;

  const FavoriteState({
    this.favoriteIds = const <String>{},
    this.action = FavoriteAction.idle,
    this.actionId = 0,
  });

  bool isFavorite(Object recipeId) {
    return favoriteIds.contains(favoriteKeyFor(recipeId));
  }

  int get favoriteCount {
    return favoriteIds.length;
  }

  Iterable<String> get backendFavoriteIds {
    return favoriteIds
        .where((id) => id.startsWith('backend:'))
        .map((id) => id.substring('backend:'.length));
  }

  FavoriteState copyWith({
    Set<String>? favoriteIds,
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
