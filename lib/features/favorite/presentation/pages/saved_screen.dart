import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';
import '../../data/models/saved_recipe.dart';
import '../../../../services/local_storage_service.dart';
import '../../../../core/router/recipe_detail_route_args.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<FavoriteCubit, FavoriteState>(
          buildWhen: (previous, current) {
            return previous.favoriteIds != current.favoriteIds ||
                previous.actionId != current.actionId;
          },
          builder: (context, favoriteState) {
            final recipes = LocalStorageService.savedBackendRecipes
                .where((recipe) => favoriteState.isFavorite(recipe.id))
                .toList();

            if (recipes.isEmpty) {
              return const _EmptySavedState();
            }

            return _SavedContent(recipes: recipes);
          },
        ),
      ),
    );
  }
}

class _SavedContent extends StatelessWidget {
  final List<SavedRecipe> recipes;

  const _SavedContent({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              itemCount: recipes.length + 1,
              separatorBuilder: (_, index) {
                if (index == 0) {
                  return const SizedBox(height: 18);
                }

                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SavedHeader(count: recipes.length, colors: colors);
                }

                final recipe = recipes[index - 1];

                return _SavedRecipeCard(recipe: recipe);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SavedHeader extends StatelessWidget {
  final int count;
  final ColorScheme colors;

  const _SavedHeader({required this.count, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resep Tersimpan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Resep yang ingin kamu masak lagi nanti.',
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            '$count resep',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _SavedRecipeCard extends StatelessWidget {
  final SavedRecipe recipe;

  const _SavedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            '/catalog-recipe/${recipe.id}',
            extra: RecipeDetailRouteArgs(
              recipe: recipe.toAiRecipe(),
              isAiRecommendation: false,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SavedRecipeImage(imageUrl: recipe.imageUrl),

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
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 17,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${recipe.ingredientCount} bahan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.bookmark_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tersimpan di RacikAI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              BlocBuilder<FavoriteCubit, FavoriteState>(
                buildWhen: (previous, current) {
                  return previous.favoriteIds != current.favoriteIds;
                },
                builder: (context, favoriteState) {
                  return IconButton(
                    tooltip: 'Hapus dari tersimpan',
                    onPressed: () {
                      context.read<FavoriteCubit>().toggleBackendFavorite(
                        recipe,
                      );
                    },
                    icon: Icon(Icons.favorite_rounded, color: colors.primary),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedRecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _SavedRecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: 96,
        height: 96,
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return _placeholder(colors);
                },
              )
            : _placeholder(colors),
      ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded, size: 36, color: colors.primary),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 50,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 26),

              Text(
                'Belum ada resep tersimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Temukan resep yang kamu suka di halaman Search, '
                'lalu ketuk ikon hati untuk menyimpannya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 17,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Free: maksimal '
                      '${FavoriteCubit.freeFavoriteLimit} resep',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimaryContainer,
                      ),
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
