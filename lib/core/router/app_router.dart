import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../../features/recipe/domain/entities/recipe_entity.dart';
import '../../features/recipe/domain/usecases/get_recipe_by_id.dart';
import '../../screens/cooking_mode_screen.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/ingredient_finder_screen.dart';
import '../../screens/ingredient_result_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/meal_planner_screen.dart';
import '../../screens/premium_screen.dart';
import '../../screens/recipe_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const MainScreen();
      },
    ),

    GoRoute(
      path: '/recipe/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');

        return _RecipeRouteLoader(recipeId: id);
      },
    ),

    GoRoute(
      path: '/recipe/:id/cook',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');

        return _RecipeRouteLoader(recipeId: id, cookingMode: true);
      },
    ),

    GoRoute(
      path: '/ingredients',
      builder: (context, state) {
        return const IngredientFinderScreen();
      },
    ),

    GoRoute(
      path: '/ingredients/results',
      builder: (context, state) {
        final ingredients = state.extra as List<String>? ?? <String>[];

        return IngredientResultScreen(selectedIngredients: ingredients);
      },
    ),

    GoRoute(
      path: '/premium',
      builder: (context, state) {
        return const PremiumScreen();
      },
    ),

    GoRoute(
      path: '/meal-planner',
      builder: (context, state) {
        return const MealPlannerScreen();
      },
    ),

    GoRoute(
      path: '/profile/edit',
      builder: (context, state) {
        final data = state.extra as Map<String, String>? ?? <String, String>{};

        return EditProfileScreen(
          initialName: data['name'] ?? 'Guest User',
          initialEmail: data['email'] ?? 'guest@racikai.app',
          initialPreference: data['preference'] ?? 'Tidak ada',
        );
      },
    ),
  ],

  errorBuilder: (context, state) {
    return const _RouteErrorScreen(
      message: 'Halaman yang kamu cari tidak ditemukan.',
    );
  },
);

class _RecipeRouteLoader extends StatefulWidget {
  final int? recipeId;
  final bool cookingMode;

  const _RecipeRouteLoader({required this.recipeId, this.cookingMode = false});

  @override
  State<_RecipeRouteLoader> createState() => _RecipeRouteLoaderState();
}

class _RecipeRouteLoaderState extends State<_RecipeRouteLoader> {
  late final Future<RecipeEntity?> recipeFuture;

  @override
  void initState() {
    super.initState();

    if (widget.recipeId == null) {
      recipeFuture = Future<RecipeEntity?>.value(null);
    } else {
      recipeFuture = sl<GetRecipeById>()(widget.recipeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecipeEntity?>(
      future: recipeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const _RouteErrorScreen(
            message: 'Terjadi kesalahan saat memuat resep.',
          );
        }

        final recipe = snapshot.data;

        if (recipe == null) {
          return const _RouteErrorScreen(message: 'Resep tidak ditemukan.');
        }

        if (widget.cookingMode) {
          return CookingModeScreen(recipe: recipe);
        }

        return RecipeDetailScreen(recipe: recipe);
      },
    );
  }
}

class _RouteErrorScreen extends StatelessWidget {
  final String message;

  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: colors.primary,
              ),

              const SizedBox(height: 20),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
