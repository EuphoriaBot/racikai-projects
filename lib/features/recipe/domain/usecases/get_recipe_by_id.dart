import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipeById {
  final RecipeRepository repository;

  const GetRecipeById(this.repository);

  Future<RecipeEntity?> call(int id) {
    return repository.getRecipeById(id);
  }
}
