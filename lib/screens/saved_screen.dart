import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../cubits/favorite/favorite_cubit.dart';
import '../cubits/favorite/favorite_state.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeCubit>()..loadRecipes(),
      child: const _SavedContent(),
    );
  }
}

class _SavedContent extends StatelessWidget {
  const _SavedContent();

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, recipeState) {
            if (recipeState is RecipeInitial || recipeState is RecipeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (recipeState is RecipeError) {
              return _SavedError(
                message: recipeState.message,
                onRetry: () {
                  context.read<RecipeCubit>().loadRecipes();
                },
              );
            }

            if (recipeState is! RecipeLoaded) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<FavoriteCubit, FavoriteState>(
              builder: (context, favoriteState) {
                final favorites = recipeState.recipes
                    .where(
                      (recipe) => favoriteState.favoriteIds.contains(recipe.id),
                    )
                    .toList();

                if (favorites.isEmpty) {
                  return const _EmptySavedState();
                }

                return _SavedRecipeList(recipes: favorites);
              },
            );
          },
        ),
      ),
    );
  }
}

class _SavedRecipeList extends StatelessWidget {
  final List<RecipeEntity> recipes;

  const _SavedRecipeList({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      itemCount: recipes.length + 1,
      separatorBuilder: (_, index) {
        if (index == 0) {
          return const SizedBox(height: 16);
        }

        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
            children: [
              Text(
                '${recipes.length} resep tersimpan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          );
        }

        final recipe = recipes[index - 1];

        return _SavedRecipeCard(recipe: recipe);
      },
    );
  }
}

class _SavedRecipeCard extends StatelessWidget {
  final RecipeEntity recipe;

  const _SavedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          context.push('/recipe/${recipe.id}');
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 86,
                height: 86,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 42)),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      recipe.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 17,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          recipe.duration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Hapus dari tersimpan',
                onPressed: () {
                  context.read<FavoriteCubit>().toggleFavorite(recipe.id);
                },
                icon: Icon(Icons.favorite_rounded, color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(36, 40, 36, 120),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 26),

            Text(
              'Belum ada yang disimpan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Simpan resep yang ingin kamu coba nanti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Ketuk ikon hati pada resep untuk menyimpannya di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: colors.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SavedError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: colors.error),

            const SizedBox(height: 16),

            Text(
              'Resep tersimpan gagal dimuat',
              textAlign: TextAlign.center,
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
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
