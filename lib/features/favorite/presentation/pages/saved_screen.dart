import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/recipe_detail_route_args.dart';
import '../../../../services/local_storage_service.dart';
import '../../data/models/saved_recipe.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final horizontalPadding = _horizontalPadding(width);

        final isGrid = width >= 700;

        int columns = 1;

        if (width >= 1050) {
          columns = 3;
        } else if (width >= 700) {
          columns = 2;
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  10,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SavedBrandHeader(),

                    const SizedBox(height: 12),

                    _SavedHeader(count: recipes.length),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            if (!isGrid)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  24,
                ),
                sliver: SliverList.separated(
                  itemCount: recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _SavedRecipeListCard(recipe: recipes[index]);
                  },
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  24,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _SavedRecipeGridCard(recipe: recipes[index]);
                  }, childCount: recipes.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 260,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  double _horizontalPadding(double width) {
    if (width > 1140) {
      return (width - 1100) / 2;
    }

    if (width >= 700) {
      return 24;
    }

    return 16;
  }
}

class _SavedBrandHeader extends StatelessWidget {
  const _SavedBrandHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RacikAI',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Aplikasi Resep Makanan',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/racikai_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 1.5,
          color: colors.outlineVariant,
        ),
      ],
    );
  }
}

class _SavedHeader extends StatelessWidget {
  final int count;

  const _SavedHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'Favorit kamu',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              color: colors.onSurface,
            ),
          ),
        ),

        Text(
          '$count resep',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SavedRecipeListCard extends StatelessWidget {
  final SavedRecipe recipe;

  const _SavedRecipeListCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openRecipe(context, recipe);
        },
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              _SavedRecipeImage(
                imageUrl: recipe.imageUrl,
                width: 92,
                height: 92,
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_outlined,
                          size: 14,
                          color: colors.primary,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '${recipe.ingredientCount} bahan',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              _RemoveFavoriteButton(recipe: recipe),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedRecipeGridCard extends StatelessWidget {
  final SavedRecipe recipe;

  const _SavedRecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openRecipe(context, recipe);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SavedRecipeImage(
                      imageUrl: recipe.imageUrl,
                      width: double.infinity,
                      height: 180,
                      borderRadius: 0,
                    ),

                    Positioned(
                      top: 10,
                      right: 10,
                      child: _RemoveFavoriteButton(
                        recipe: recipe,
                        overlay: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 14,
                  color: colors.primary,
                ),

                const SizedBox(width: 5),

                Text(
                  '${recipe.ingredientCount} bahan',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const Spacer(),

                Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveFavoriteButton extends StatelessWidget {
  final SavedRecipe recipe;
  final bool overlay;

  const _RemoveFavoriteButton({required this.recipe, this.overlay = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: IconButton(
        tooltip: 'Hapus dari tersimpan',
        onPressed: () {
          context.read<FavoriteCubit>().toggleBackendFavorite(recipe);
        },

        // Area sentuh tetap nyaman
        constraints: const BoxConstraints.tightFor(width: 44, height: 44),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),

        // Lingkaran visual lebih kecil
        icon: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: overlay
                ? colors.surface.withValues(alpha: 0.94)
                : colors.secondaryContainer.withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_rounded,
            size: 18,
            color: colors.secondary,
          ),
        ),
      ),
    );
  }
}

class _SavedRecipeImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const _SavedRecipeImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final image = hasImage
        ? Image.network(
            imageUrl!,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return _placeholder(colors);
            },
          )
        : _placeholder(colors);

    if (borderRadius == 0) {
      return SizedBox(width: width, height: height, child: image);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: width, height: height, child: image),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      width: width,
      height: height,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: width >= 150 ? 38 : 30,
        color: colors.primary.withValues(alpha: 0.72),
      ),
    );
  }
}

void _openRecipe(BuildContext context, SavedRecipe recipe) {
  context.push(
    '/catalog-recipe/${recipe.id}',
    extra: RecipeDetailRouteArgs(
      recipe: recipe.toAiRecipe(),
      isAiRecommendation: false,
    ),
  );
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 120),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 33,
                  color: colors.primary,
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Belum ada resep tersimpan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                'Simpan resep yang kamu suka '
                'agar mudah ditemukan lagi nanti.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      size: 16,
                      color: colors.secondary,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Simpan resep favorit tanpa batas',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
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
