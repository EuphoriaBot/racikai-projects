import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/dummy_recipes.dart';
import '../../models/recipe.dart';
import '../../screens/edit_profile_screen.dart';
import '../../screens/ingredient_finder_screen.dart';
import '../../screens/ingredient_result_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/meal_planner_screen.dart';
import '../../screens/premium_screen.dart';
import '../../screens/recipe_detail_screen.dart';

Recipe? _findRecipeById(int? id) {
  if (id == null) {
    return null;
  }

  for (final recipe in dummyRecipes) {
    if (recipe.id == id) {
      return recipe;
    }
  }

  return null;
}

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

        final recipe = _findRecipeById(id);

        if (recipe == null) {
          return const _RouteErrorScreen(message: 'Resep tidak ditemukan.');
        }

        return RecipeDetailScreen(recipe: recipe);
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
        final ingredients = state.extra as List<String>? ?? [];

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
        final data = state.extra as Map<String, String>? ?? {};

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

              const SizedBox(height: 18),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
