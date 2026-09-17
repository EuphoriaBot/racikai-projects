import '../../../../data/dummy_recipes.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getRecipes();

  Future<RecipeModel?> getRecipeById(int id);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  @override
  Future<List<RecipeModel>> getRecipes() async {
    return dummyRecipes.map((recipe) {
      return RecipeModel(
        id: recipe.id,
        title: recipe.title,
        category: recipe.category,
        duration: recipe.duration,
        emoji: recipe.emoji,
        description: recipe.description,
        ingredients: List<String>.from(recipe.ingredients),
        instructions: List<String>.from(recipe.instructions),
      );
    }).toList();
  }

  @override
  Future<RecipeModel?> getRecipeById(int id) async {
    for (final recipe in dummyRecipes) {
      if (recipe.id == id) {
        return RecipeModel(
          id: recipe.id,
          title: recipe.title,
          category: recipe.category,
          duration: recipe.duration,
          emoji: recipe.emoji,
          description: recipe.description,
          ingredients: List<String>.from(recipe.ingredients),
          instructions: List<String>.from(recipe.instructions),
        );
      }
    }

    return null;
  }
}
