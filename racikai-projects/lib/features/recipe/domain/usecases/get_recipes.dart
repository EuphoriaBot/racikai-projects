import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetRecipes {
  final RecipeRepository repository;

  const GetRecipes(this.repository);

  Future<List<RecipeEntity>> call() {
    return repository.getRecipes();
  }
}
