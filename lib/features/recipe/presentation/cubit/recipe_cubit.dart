import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_recipes.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final GetRecipes getRecipes;

  RecipeCubit({required this.getRecipes}) : super(const RecipeInitial());

  Future<void> loadRecipes() async {
    emit(const RecipeLoading());

    try {
      final recipes = await getRecipes();

      emit(RecipeLoaded(recipes: recipes));
    } catch (error) {
      emit(RecipeError(message: 'Gagal memuat resep: $error'));
    }
  }
}
