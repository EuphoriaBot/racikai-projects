import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource localDataSource;

  const RecipeRepositoryImpl({required this.localDataSource});

  @override
  Future<List<RecipeEntity>> getRecipes() async {
    return localDataSource.getRecipes();
  }

  @override
  Future<RecipeEntity?> getRecipeById(int id) async {
    return localDataSource.getRecipeById(id);
  }
}
