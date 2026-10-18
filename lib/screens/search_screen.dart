import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/router/recipe_detail_route_args.dart';
import '../features/favorite/data/models/saved_recipe.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';
import '../features/recipe/data/models/catalog_recipe.dart';
import '../services/recipe_catalog_service.dart';
import '../widgets/recipe_search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final RecipeCatalogService _catalogService = RecipeCatalogService();

  Timer? _debounce;

  final List<String> _categories = const [
    'Semua',
    'Ayam',
    'Daging',
    'Nasi',
    'Pasta',
    'Sayur',
    'Dessert',
  ];

  List<CatalogRecipe> _recipes = [];

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;

  int _page = 1;
  int _total = 0;

  bool _hasMore = false;

  int _requestVersion = 0;

  @override
  void initState() {
    super.initState();

    _loadRecipes(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _catalogService.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRecipes(reset: true);
    });
  }

  void _resetSearchFilters() {
    _debounce?.cancel();
    _searchController.clear();

    setState(() {
      _searchQuery = '';
      _selectedCategory = 'Semua';
    });

    _loadRecipes(reset: true);
  }

  void _selectCategory(String category) {
    if (_selectedCategory == category) {
      return;
    }

    setState(() {
      _selectedCategory = category;
    });

    _loadRecipes(reset: true);
  }

  Future<void> _loadRecipes({required bool reset}) async {
    if (reset) {
      _requestVersion++;

      setState(() {
        _page = 1;
        _recipes = [];
        _total = 0;
        _hasMore = false;
        _isLoading = true;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } else {
      if (_isLoadingMore || !_hasMore) {
        return;
      }

      setState(() {
        _isLoadingMore = true;
      });
    }

    final version = _requestVersion;

    final requestedPage = reset ? 1 : _page + 1;

    try {
      final result = await _catalogService.getRecipes(
        query: _searchQuery,
        category: _selectedCategory,
        page: requestedPage,
        limit: 24,
      );

      if (!mounted || version != _requestVersion) {
        return;
      }

      setState(() {
        if (reset) {
          _recipes = result.recipes;
        } else {
          _recipes.addAll(result.recipes);
        }

        _page = result.page;
        _total = result.total;
        _hasMore = result.hasMore;

        _errorMessage = null;
      });
    } on RecipeCatalogException catch (error) {
      if (!mounted || version != _requestVersion) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _openRecipe(CatalogRecipe recipe) {
    context.push(
      '/catalog-recipe/${recipe.id}',
      extra: RecipeDetailRouteArgs(
        recipe: recipe.toAiRecipe(),
        isAiRecommendation: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return BlocListener<FavoriteCubit, FavoriteState>(
      listenWhen: (previous, current) {
        return previous.actionId != current.actionId;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (state.action == FavoriteAction.added) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 900),
              content: Text('Resep disimpan'),
            ),
          );
        }

        if (state.action == FavoriteAction.removed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 900),
              content: Text('Resep dihapus dari tersimpan'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadRecipes(reset: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SearchHeader(),

                            const SizedBox(height: 14),

                            _SearchField(
                              controller: _searchController,
                              query: _searchQuery,
                              onChanged: _onSearchChanged,
                              onClear: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            ),

                            const SizedBox(height: 18),

                            _CategoryChips(
                              categories: _categories,
                              selectedCategory: _selectedCategory,
                              onSelected: _selectCategory,
                            ),

                            const SizedBox(height: 28),

                            _ResultHeader(
                              heading: _headingText,
                              total: _total,
                              isLoading: _isLoading,
                              hasError: _errorMessage != null,
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                if (_isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _SearchError(
                      message: _errorMessage!,
                      onRetry: () {
                        _loadRecipes(reset: true);
                      },
                    ),
                  )
                else if (_recipes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptySearchResult(
                      searchQuery: _searchQuery,
                      hasActiveFilters:
                          _searchQuery.trim().isNotEmpty ||
                          _selectedCategory != 'Semua',
                      onReset: _resetSearchFilters,
                    ),
                  )
                else ...[
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.crossAxisExtent;

                      final horizontalPadding = _horizontalPadding(screenWidth);

                      final usableWidth = screenWidth - (horizontalPadding * 2);

                      int columns;

                      if (usableWidth >= 900) {
                        columns = 4;
                      } else if (usableWidth >= 600) {
                        columns = 3;
                      } else {
                        columns = 2;
                      }

                      const spacing = 14.0;

                      final itemWidth =
                          (usableWidth - ((columns - 1) * spacing)) / columns;

                      final itemHeight = (itemWidth * 0.72) + 82;

                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          20,
                        ),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final recipe = _recipes[index];

                            return _CatalogRecipeCard(
                              recipe: recipe,
                              onTap: () {
                                _openRecipe(recipe);
                              },
                            );
                          }, childCount: _recipes.length),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: spacing,
                                mainAxisSpacing: 22,
                                mainAxisExtent: itemHeight,
                              ),
                        ),
                      );
                    },
                  ),

                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
                          child: _LoadMoreArea(
                            hasMore: _hasMore,
                            isLoading: _isLoadingMore,
                            loaded: _recipes.length,
                            total: _total,
                            onPressed: () {
                              _loadRecipes(reset: false);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _horizontalPadding(double width) {
    if (width > 1132) {
      return (width - 1100) / 2;
    }

    if (width >= 600) {
      return 24;
    }

    return 16;
  }

  String get _headingText {
    if (_searchQuery.trim().isNotEmpty || _selectedCategory != 'Semua') {
      return 'Hasil pencarian';
    }

    return 'Semua resep';
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jelajahi resep',
            style: TextStyle(
              fontSize: 26,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: colors.onPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Temukan resep yang cocok untuk menu hari ini.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.onPrimary.withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 16),

          RecipeSearchBar(
            controller: controller,
            query: query,
            onChanged: onChanged,
            onClear: onClear,
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) {
          return const SizedBox(width: 9);
        },
        itemBuilder: (context, index) {
          final category = categories[index];

          final selected = selectedCategory == category;

          return Material(
            color: selected
                ? colors.primary
                : colors.primaryContainer.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () {
                onSelected(category);
              },
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? colors.onPrimary
                        : colors.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  final String heading;
  final int total;
  final bool isLoading;
  final bool hasError;

  const _ResultHeader({
    required this.heading,
    required this.total,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            heading,
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              color: colors.onSurface,
            ),
          ),
        ),
        if (!isLoading && !hasError && total > 0)
          Text(
            '${_formatNumber(total)} resep',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  static String _formatNumber(int value) {
    final source = value.toString();

    return source.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}

class _CatalogRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _CatalogRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxWidth * 0.72;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _RecipeImage(imageUrl: recipe.imageUrl),
                        Positioned(
                          top: 9,
                          right: 9,
                          child: _FavoriteButton(recipe: recipe),
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
                    fontSize: 14,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu_outlined,
                      size: 14,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${recipe.ingredientCount} bahan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final CatalogRecipe recipe;

  const _FavoriteButton({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<FavoriteCubit, FavoriteState>(
      buildWhen: (previous, current) {
        return previous.favoriteIds != current.favoriteIds;
      },
      builder: (context, state) {
        final isFavorite = state.isFavorite(recipe.id);

        return Material(
          color: colors.surface.withValues(alpha: 0.94),
          shape: const CircleBorder(),
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              context.read<FavoriteCubit>().toggleBackendFavorite(
                SavedRecipe.fromCatalogRecipe(recipe),
              );
            },
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 19,
                color: isFavorite ? colors.secondary : colors.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: colors.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, _, _) {
          return _placeholder(colors);
        },
      );
    }

    return _placeholder(colors);
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      width: double.infinity,
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 36,
        color: colors.primary.withValues(alpha: 0.72),
      ),
    );
  }
}

class _LoadMoreArea extends StatelessWidget {
  final bool hasMore;
  final bool isLoading;
  final int loaded;
  final int total;
  final VoidCallback onPressed;

  const _LoadMoreArea({
    required this.hasMore,
    required this.isLoading,
    required this.loaded,
    required this.total,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (!hasMore) {
      return Center(
        child: Text(
          'Menampilkan $loaded dari '
          '${_formatNumber(total)} resep',
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
      );
    }

    return Center(
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.expand_more_rounded),
        label: Text(isLoading ? 'Memuat...' : 'Muat lebih banyak'),
      ),
    );
  }

  static String _formatNumber(int value) {
    final source = value.toString();

    return source.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.');
  }
}

class _EmptySearchResult extends StatelessWidget {
  final String searchQuery;
  final bool hasActiveFilters;
  final VoidCallback onReset;

  const _EmptySearchResult({
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon pencarian kosong
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 30,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 14),

            // Judul
            Text(
              'Tidak ada resep yang cocok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // Deskripsi
            Text(
              searchQuery.trim().isNotEmpty
                  ? 'Coba gunakan nama resep atau bahan '
                        'yang berbeda.'
                  : hasActiveFilters
                  ? 'Coba pilih kategori lainnya.'
                  : 'Belum ada resep yang tersedia saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),

            // Tombol reset pencarian dan filter
            if (hasActiveFilters) ...[
              const SizedBox(height: 18),

              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset pencarian'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.outlineVariant),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
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
            Icon(Icons.cloud_off_outlined, size: 50, color: colors.error),
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
