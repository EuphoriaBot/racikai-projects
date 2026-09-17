import '../entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getRecipes();

  Future<RecipeEntity?> getRecipeById(int id);
}
