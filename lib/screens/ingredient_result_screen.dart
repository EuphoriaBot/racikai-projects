import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';

class IngredientResultScreen extends StatelessWidget {
  final List<String> selectedIngredients;

  const IngredientResultScreen({super.key, required this.selectedIngredients});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeCubit>()..loadRecipes(),
      child: _IngredientResultContent(selectedIngredients: selectedIngredients),
    );
  }
}

class _IngredientResultContent extends StatelessWidget {
  final List<String> selectedIngredients;

  const _IngredientResultContent({required this.selectedIngredients});

  bool ingredientMatches(String recipeIngredient, String selectedIngredient) {
    final recipeText = recipeIngredient.toLowerCase();

    final selectedText = selectedIngredient.toLowerCase();

    return recipeText.contains(selectedText) ||
        selectedText.contains(recipeText);
  }

  int calculateMatchedIngredients(RecipeEntity recipe) {
    int matchCount = 0;

    for (final recipeIngredient in recipe.ingredients) {
      final matched = selectedIngredients.any((selectedIngredient) {
        return ingredientMatches(recipeIngredient, selectedIngredient);
      });

      if (matched) {
        matchCount++;
      }
    }

    return matchCount;
  }

  double calculateMatchPercentage(RecipeEntity recipe) {
    if (recipe.ingredients.isEmpty) {
      return 0;
    }

    final matched = calculateMatchedIngredients(recipe);

    return matched / recipe.ingredients.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Resep yang Cocok',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<RecipeCubit, RecipeState>(
        builder: (context, state) {
          if (state is RecipeInitial || state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecipeError) {
            return _RecipeError(
              message: state.message,
              onRetry: () {
                context.read<RecipeCubit>().loadRecipes();
              },
            );
          }

          if (state is RecipeLoaded) {
            final matchedRecipes = state.recipes
                .where((recipe) => calculateMatchedIngredients(recipe) > 0)
                .toList();

            matchedRecipes.sort((a, b) {
              return calculateMatchPercentage(b)
                  .compareTo(calculateMatchPercentage(a));
            });

            if (matchedRecipes.isEmpty) {
              return const _NoResult();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(
                  'Berdasarkan bahanmu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${selectedIngredients.length} bahan dipilih • '
                  '${matchedRecipes.length} resep ditemukan',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: selectedIngredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      backgroundColor: colors.primaryContainer,
                      side: BorderSide.none,
                      labelStyle: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                ...matchedRecipes.map((recipe) {
                  final matched = calculateMatchedIngredients(recipe);

                  final percentage = calculateMatchPercentage(recipe).round();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IngredientRecipeCard(
                      recipe: recipe,
                      matchPercentage: percentage,
                      matchedIngredients: matched,
                    ),
                  );
                }),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _IngredientRecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final int matchPercentage;
  final int matchedIngredients;

  const _IngredientRecipeCard({
    required this.recipe,
    required this.matchPercentage,
    required this.matchedIngredients,
  });

  Color getMatchColor(ColorScheme colors) {
    if (matchPercentage >= 70) {
      return colors.tertiary;
    }

    if (matchPercentage >= 40) {
      return colors.primary;
    }

    return colors.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final matchColor = getMatchColor(colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/recipe/${recipe.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 44)),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: matchColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '$matchPercentage% cocok',
                            style: TextStyle(
                              color: matchColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$matchedIngredients dari '
                      '${recipe.ingredients.length} bahan tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(Icons.schedule, size: 15, color: colors.primary),

                        const SizedBox(width: 5),

                        Text(
                          recipe.duration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface,
                          ),
                        ),

                        const Spacer(),

                        Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 68,
              color: colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),

            const SizedBox(height: 18),

            Text(
              'Belum ada resep yang cocok',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Coba pilih bahan lain atau tambahkan lebih banyak bahan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RecipeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),

            const SizedBox(height: 16),

            Text(
              'Gagal Memuat Resep',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
