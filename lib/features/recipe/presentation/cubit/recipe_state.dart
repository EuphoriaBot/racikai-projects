import 'package:equatable/equatable.dart';

import '../../domain/entities/recipe_entity.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

class RecipeLoading extends RecipeState {
  const RecipeLoading();
}

class RecipeLoaded extends RecipeState {
  final List<RecipeEntity> recipes;

  const RecipeLoaded({required this.recipes});

  @override
  List<Object?> get props => [recipes];
}

class RecipeError extends RecipeState {
  final String message;

  const RecipeError({required this.message});

  @override
  List<Object?> get props => [message];
}
