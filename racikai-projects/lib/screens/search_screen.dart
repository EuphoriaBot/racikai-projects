import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/service_locator.dart';
import '../cubits/favorite/favorite_cubit.dart';
import '../cubits/favorite/favorite_state.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RecipeCubit>()..loadRecipes(),
      child: const _SearchContent(),
    );
  }
}

class _SearchContent extends StatefulWidget {
  const _SearchContent();

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = const [
    'Semua',
    'Ayam',
    'Daging',
    'Nasi',
    'Pasta',
    'Sayur',
    'Dessert',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RecipeEntity> _filterRecipes(List<RecipeEntity> recipes) {
    return recipes.where((recipe) {
      final query = _searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          recipe.title.toLowerCase().contains(query) ||
          recipe.category.toLowerCase().contains(query) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(query),
          );

      final matchesCategory =
          _selectedCategory == 'Semua' || recipe.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<RecipeCubit, RecipeState>(
          builder: (context, state) {
            if (state is RecipeInitial || state is RecipeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecipeError) {
              return _SearchError(
                message: state.message,
                onRetry: () {
                  context.read<RecipeCubit>().loadRecipes();
                },
              );
            }

            if (state is! RecipeLoaded) {
              return const SizedBox.shrink();
            }

            final filteredRecipes = _filterRecipes(state.recipes);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari resep atau bahan...',
                              hintStyle: TextStyle(
                                color: colors.onSurfaceVariant,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                              suffixIcon: _searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Hapus pencarian',
                                      onPressed: () {
                                        _searchController.clear();

                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                      icon: Icon(
                                        Icons.close_rounded,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          height: 46,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final category = _categories[index];

                              final selected = _selectedCategory == category;

                              return ChoiceChip(
                                label: Text(category),
                                selected: selected,
                                showCheckmark: false,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? colors.onPrimary
                                      : colors.onSurface,
                                ),
                                selectedColor: colors.primary,
                                backgroundColor: colors.surface,
                                side: BorderSide(
                                  color: selected
                                      ? colors.primary
                                      : colors.outlineVariant,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Text(
                              _searchQuery.isNotEmpty ||
                                      _selectedCategory != 'Semua'
                                  ? '${filteredRecipes.length} resep ditemukan'
                                  : 'Semua resep',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                if (filteredRecipes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptySearchResult(searchQuery: _searchQuery),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.crossAxisExtent;

                        int crossAxisCount = 2;

                        if (width >= 900) {
                          crossAxisCount = 4;
                        } else if (width >= 600) {
                          crossAxisCount = 3;
                        }

                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _SearchRecipeCard(
                              recipe: filteredRecipes[index],
                            );
                          }, childCount: filteredRecipes.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.72,
                              ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchRecipeCard extends StatelessWidget {
  final RecipeEntity recipe;

  const _SearchRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/recipe/${recipe.id}');
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: colors.primaryContainer,
                      alignment: Alignment.center,
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),

                    Positioned(
                      top: 12,
                      right: 12,
                      child: BlocBuilder<FavoriteCubit, FavoriteState>(
                        builder: (context, favoriteState) {
                          final isFavorite = favoriteState.isFavorite(
                            recipe.id,
                          );

                          return Material(
                            color: colors.surface.withValues(alpha: 0.92),
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: isFavorite
                                  ? 'Hapus dari favorit'
                                  : 'Simpan resep',
                              onPressed: () {
                                context.read<FavoriteCubit>().toggleFavorite(
                                  recipe.id,
                                );
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? colors.primary
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      Text(
                        recipe.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 17,
                            color: colors.primary,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              recipe.duration,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  final String searchQuery;

  const _EmptySearchResult({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 20, 36, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 38,
                color: colors.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Tidak ada resep yang cocok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              searchQuery.isEmpty
                  ? 'Coba pilih kategori lainnya.'
                  : 'Coba gunakan kata kunci atau bahan yang berbeda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SearchError({required this.message, required this.onRetry});

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
              'Resep gagal dimuat',
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
