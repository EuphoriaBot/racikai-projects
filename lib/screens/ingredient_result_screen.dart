import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/router/recipe_detail_route_args.dart';
import '../features/favorite/data/models/saved_recipe.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';
import '../features/recipe/data/models/catalog_recipe.dart';
import '../services/recipe_catalog_service.dart';

class IngredientResultScreen extends StatefulWidget {
  final List<String> selectedIngredients;

  const IngredientResultScreen({super.key, required this.selectedIngredients});

  @override
  State<IngredientResultScreen> createState() => _IngredientResultScreenState();
}

class _IngredientResultScreenState extends State<IngredientResultScreen> {
  final RecipeCatalogService _catalogService = RecipeCatalogService();

  List<CatalogRecipe> _recipes = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;

  String? _errorMessage;

  int _page = 1;
  int _total = 0;
  bool _hasMore = false;

  int _requestVersion = 0;

  static const Map<String, String> _ingredientQueryMap = {
    'Ayam': 'chicken',
    'Daging sapi': 'beef',
    'Telur': 'egg',
    'Nasi': 'rice',
    'Pasta': 'pasta',
    'Bawang putih': 'garlic',
    'Bawang merah': 'shallot',
    'Bawang bombai': 'onion',
    'Kecap': 'soy sauce',
    'Saus teriyaki': 'teriyaki',
    'Saus tiram': 'oyster sauce',
    'Cabai': 'chili',
    'Wortel': 'carrot',
    'Brokoli': 'broccoli',
    'Kol': 'cabbage',
    'Kentang': 'potato',
    'Santan': 'coconut milk',
    'Susu': 'milk',
    'Keju': 'cheese',
    'Tepung': 'flour',
    'Gula': 'sugar',
    'Minyak': 'oil',
    'Garam': 'salt',
  };

  @override
  void initState() {
    super.initState();
    _loadRecipes(reset: true);
  }

  @override
  void dispose() {
    _catalogService.dispose();
    super.dispose();
  }

  String get _backendQuery {
    return widget.selectedIngredients
        .map((ingredient) {
          return _ingredientQueryMap[ingredient] ?? ingredient.toLowerCase();
        })
        .join(' ');
  }

  Future<void> _loadRecipes({required bool reset}) async {
    if (reset) {
      _requestVersion++;

      setState(() {
        _recipes = [];
        _page = 1;
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
        query: _backendQuery,
        category: 'Semua',
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

  void _changeIngredients() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/ingredients');
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
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text(
            'Resep dari bahan',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadRecipes(reset: true),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _RecipeError(
              message: _errorMessage!,
              onRetry: () {
                _loadRecipes(reset: true);
              },
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isCompact = width < 420;

        final crossAxisCount = isCompact
            ? 1
            : width >= 1050
            ? 4
            : width >= 700
            ? 3
            : 2;

        final horizontalPadding = width > 1148
            ? (width - 1100) / 2
            : width >= 700
            ? 24.0
            : 16.0;

        final cardHeight = isCompact
            ? 126.0
            : crossAxisCount == 2
            ? 270.0
            : 300.0;

        if (_recipes.isEmpty) {
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _IngredientHeader(
                  selectedIngredients: widget.selectedIngredients,
                  total: 0,
                  onChangeIngredients: _changeIngredients,
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _NoResult(),
              ),
            ],
          );
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _IngredientHeader(
                selectedIngredients: widget.selectedIngredients,
                total: _total,
                onChangeIngredients: _changeIngredients,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                22,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  mainAxisExtent: cardHeight,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final recipe = _recipes[index];

                  return _IngredientRecipeCard(
                    recipe: recipe,
                    selectedIngredientCount: widget.selectedIngredients.length,
                    compact: isCompact,
                    onTap: () {
                      _openRecipe(recipe);
                    },
                  );
                }, childCount: _recipes.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  0,
                  horizontalPadding,
                  40,
                ),
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
        );
      },
    );
  }
}

class _IngredientHeader extends StatelessWidget {
  final List<String> selectedIngredients;
  final int total;
  final VoidCallback onChangeIngredients;

  const _IngredientHeader({
    required this.selectedIngredients,
    required this.total,
    required this.onChangeIngredients,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hasil pencarian',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: colors.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      '$total resep',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Berdasarkan ${selectedIngredients.length} '
                'bahan yang kamu pilih',
                style: TextStyle(
                  fontSize: 12.5,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 7,
                runSpacing: 8,
                children: [
                  for (final ingredient in selectedIngredients)
                    Chip(
                      avatar: Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: colors.primary,
                      ),
                      label: Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      backgroundColor: colors.primaryContainer.withValues(
                        alpha: 0.7,
                      ),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      visualDensity: VisualDensity.compact,
                    ),

                  ActionChip(
                    avatar: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                    label: Text(
                      'Ubah bahan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),
                    onPressed: onChangeIngredients,
                    backgroundColor: colors.surface,
                    side: BorderSide(color: colors.outlineVariant),
                    shape: const StadiumBorder(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IngredientRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final int selectedIngredientCount;
  final bool compact;
  final VoidCallback onTap;

  const _IngredientRecipeCard({
    required this.recipe,
    required this.selectedIngredientCount,
    required this.onTap,
    this.compact = false,
  });

  Widget _buildPhoto(BuildContext context, ColorScheme colors) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _RecipeImage(imageUrl: recipe.imageUrl),

        Positioned(
          top: 6,
          right: 6,
          child: BlocBuilder<FavoriteCubit, FavoriteState>(
            buildWhen: (previous, current) {
              return previous.favoriteIds != current.favoriteIds;
            },
            builder: (context, favoriteState) {
              final isFavorite = favoriteState.isFavorite(recipe.id);

              return SizedBox(
                width: 36,
                height: 36,
                child: Material(
                  color: colors.surface,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari tersimpan'
                        : 'Simpan resep',
                    onPressed: () {
                      context.read<FavoriteCubit>().toggleBackendFavorite(
                        SavedRecipe.fromCatalogRecipe(recipe),
                      );
                    },
                    iconSize: 17,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? colors.secondary
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(ColorScheme colors) {
    return Column(
      mainAxisAlignment: compact
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 14 : 14.5,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 15,
              color: colors.primary,
            ),

            const SizedBox(width: 5),

            Text(
              '${recipe.ingredientCount} bahan',
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lihat resep',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),

            const SizedBox(width: 5),

            Icon(Icons.arrow_forward_rounded, size: 15, color: colors.primary),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: compact
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 100,
                          height: 104,
                          child: _buildPhoto(context, colors),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(child: _buildDetails(colors)),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPhoto(context, colors)),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
                      child: _buildDetails(colors),
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

    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _placeholder(colors);
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          color: colors.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, _, _) {
        return _placeholder(colors);
      },
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
      child: Icon(Icons.restaurant_rounded, size: 38, color: colors.primary),
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

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 80),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 42,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Belum ada kombinasi yang cocok',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Belum ada resep di dataset yang menggunakan '
                'seluruh kombinasi bahan tersebut. '
                'Coba kurangi salah satu bahan atau pilih '
                'kombinasi lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/ingredients');
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Ubah bahan'),
              ),
            ],
          ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 58, color: colors.error),
              const SizedBox(height: 18),
              Text(
                'Resep gagal dimuat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.45, color: colors.onSurfaceVariant),
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
      ),
    );
  }
}
