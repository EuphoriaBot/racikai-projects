import '../../../../data/dummy_recipes.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getRecipes();

  Future<RecipeModel?> getRecipeById(int id);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  @override
  Future<List<RecipeModel>> getRecipes() async {
    return List<RecipeModel>.unmodifiable(dummyRecipes);
  }

  @override
  Future<RecipeModel?> getRecipeById(int id) async {
    for (final recipe in dummyRecipes) {
      if (recipe.id == id) {
        return recipe;
      }
    }

    return null;
  }
}
