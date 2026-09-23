import 'package:get_it/get_it.dart';

import '../../features/recipe/data/datasources/recipe_local_data_source.dart';
import '../../features/recipe/data/repositories/recipe_repository_impl.dart';
import '../../features/recipe/domain/repositories/recipe_repository.dart';
import '../../features/recipe/domain/usecases/get_recipe_by_id.dart';
import '../../features/recipe/domain/usecases/get_recipes.dart';
import '../../features/recipe/presentation/cubit/recipe_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  sl.registerLazySingleton<RecipeLocalDataSource>(
    () => RecipeLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetRecipes(sl()));

  sl.registerLazySingleton(() => GetRecipeById(sl()));

  sl.registerFactory(() => RecipeCubit(getRecipes: sl()));
}
