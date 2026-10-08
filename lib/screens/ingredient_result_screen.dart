import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubits/favorite/favorite_cubit.dart';
import '../cubits/favorite/favorite_state.dart';
import '../models/catalog_recipe.dart';
import '../models/saved_recipe.dart';
import '../services/recipe_catalog_service.dart';
import '../core/router/recipe_detail_route_args.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return BlocListener<FavoriteCubit, FavoriteState>(
      listenWhen: (previous, current) {
        return previous.actionId != current.actionId;
      },
      listener: (context, state) {
        if (state.action == FavoriteAction.limitReached) {
          _showFavoriteLimitDialog(context);

          return;
        }

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

    if (_recipes.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _IngredientHeader(
              selectedIngredients: widget.selectedIngredients,
              total: 0,
            ),
          ),
          const SliverFillRemaining(hasScrollBody: false, child: _NoResult()),
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
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          sliver: SliverList.separated(
            itemCount: _recipes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final recipe = _recipes[index];

              return _IngredientRecipeCard(
                recipe: recipe,
                selectedIngredientCount: widget.selectedIngredients.length,
                onTap: () {
                  _openRecipe(recipe);
                },
              );
            },
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
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
  }
}

class _IngredientHeader extends StatelessWidget {
  final List<String> selectedIngredients;
  final int total;

  const _IngredientHeader({
    required this.selectedIngredients,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                total > 0
                    ? '${selectedIngredients.length} bahan dipilih • '
                          '$total resep ditemukan'
                    : '${selectedIngredients.length} bahan dipilih',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
              ),

              const SizedBox(height: 8),

              Text(
                'Hasil diambil dari dataset resep RacikAI '
                'berdasarkan kombinasi bahan yang kamu pilih.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: selectedIngredients.map((ingredient) {
                  return Chip(
                    avatar: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
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
  final VoidCallback onTap;

  const _IngredientRecipeCard({
    required this.recipe,
    required this.selectedIngredientCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _RecipeImage(imageUrl: recipe.imageUrl),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  '$selectedIngredientCount bahan pilihan cocok',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 9),

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
                              size: 16,
                              color: colors.primary,
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                '${recipe.ingredientCount} bahan total',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
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

                  const SizedBox(width: 4),

                  BlocBuilder<FavoriteCubit, FavoriteState>(
                    buildWhen: (previous, current) {
                      return previous.favoriteIds != current.favoriteIds;
                    },
                    builder: (context, favoriteState) {
                      final isFavorite = favoriteState.isFavorite(recipe.id);

                      return IconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari tersimpan'
                            : 'Simpan resep',
                        onPressed: () {
                          context.read<FavoriteCubit>().toggleBackendFavorite(
                            SavedRecipe.fromCatalogRecipe(recipe),
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
                      );
                    },
                  ),
                ],
              ),
            ),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: 104,
        height: 116,
        child: imageUrl != null && imageUrl!.trim().isNotEmpty
            ? Image.network(
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
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
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
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 100),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
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
                  Icons.restaurant_menu_rounded,
                  size: 48,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Belum ada kombinasi yang cocok',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Belum ada resep di dataset yang menggunakan '
                'seluruh kombinasi bahan tersebut. '
                'Coba kembali dan kurangi salah satu bahan '
                'atau pilih kombinasi lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.55,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 22),

              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Ubah Bahan'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 60, color: colors.error),

            const SizedBox(height: 16),

            Text(
              'Resep gagal dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
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

void _showFavoriteLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: Icon(Icons.favorite_rounded, size: 42, color: colors.primary),
        title: const Text('Batas Resep Tersimpan', textAlign: TextAlign.center),
        content: Text(
          'Akun Free dapat menyimpan maksimal '
          '${FavoriteCubit.freeFavoriteLimit} resep. '
          'Upgrade ke Premium untuk menyimpan resep tanpa batas.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Nanti'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              context.push('/premium');
            },
            child: const Text('Upgrade Premium'),
          ),
        ],
      );
    },
  );
}
