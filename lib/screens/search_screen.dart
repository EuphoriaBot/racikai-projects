import 'dart:async';

import 'package:flutter/material.dart';

import '../models/catalog_recipe.dart';
import '../services/recipe_catalog_service.dart';
import 'ai_recipe_detail_screen.dart';

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiRecipeDetailScreen(
          recipe: recipe.toAiRecipe(),
          isAiRecommendation: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _loadRecipes(reset: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

                      SizedBox(
                        height: 46,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final category = _categories[index];

                            final selected = _selectedCategory == category;

                            return ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              showCheckmark: false,
                              onSelected: (_) {
                                _selectCategory(category);
                              },
                              selectedColor: colors.primary,
                              backgroundColor: colors.surface,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? colors.onPrimary
                                    : colors.onSurface,
                              ),
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

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _headingText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.onSurface,
                              ),
                            ),
                          ),

                          if (!_isLoading &&
                              _errorMessage == null &&
                              _total > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                '$_total resep',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),
                    ],
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
                  child: _EmptySearchResult(searchQuery: _searchQuery),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.crossAxisExtent;

                      int columns;

                      if (width >= 1100) {
                        columns = 4;
                      } else if (width >= 700) {
                        columns = 3;
                      } else {
                        columns = 2;
                      }

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final recipe = _recipes[index];

                          return _CatalogRecipeCard(
                            recipe: recipe,
                            onTap: () {
                              _openRecipe(recipe);
                            },
                          );
                        }, childCount: _recipes.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 300,
                        ),
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _headingText {
    if (_searchQuery.trim().isNotEmpty || _selectedCategory != 'Semua') {
      return 'Hasil pencarian';
    }

    return 'Jelajahi resep';
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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Cari resep atau bahan...',
          hintStyle: TextStyle(color: colors.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.onSurfaceVariant,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}

class _CatalogRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _CatalogRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _RecipeImage(imageUrl: recipe.imageUrl)),

              Padding(
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
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu_rounded,
                          size: 16,
                          color: colors.primary,
                        ),

                        const SizedBox(width: 6),

                        Expanded(
                          child: Text(
                            '${recipe.ingredientCount} bahan',
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
            ],
          ),
        ),
      ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.88),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.restaurant_rounded, size: 34, color: colors.primary),
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
          'Menampilkan $loaded dari $total resep',
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
              searchQuery.trim().isEmpty
                  ? 'Coba pilih kategori lainnya.'
                  : 'Coba gunakan nama resep atau bahan yang berbeda.',
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
            Icon(Icons.cloud_off_rounded, size: 56, color: colors.error),

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
