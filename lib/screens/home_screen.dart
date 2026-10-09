import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';
import '../features/recipe/data/models/catalog_recipe.dart';
import '../features/favorite/data/models/saved_recipe.dart';
import '../services/recipe_catalog_service.dart';
import '../core/router/recipe_detail_route_args.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({super.key, required this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeCatalogService _catalogService = RecipeCatalogService();

  final List<Map<String, Object>> _categories = const [
    {'name': 'Ayam', 'icon': Icons.set_meal},
    {'name': 'Daging', 'icon': Icons.restaurant},
    {'name': 'Sayur', 'icon': Icons.eco},
    {'name': 'Pasta', 'icon': Icons.ramen_dining},
    {'name': 'Dessert', 'icon': Icons.cake_outlined},
  ];

  List<CatalogRecipe> _featuredRecipes = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadFeaturedRecipes();
  }

  @override
  void dispose() {
    _catalogService.dispose();

    super.dispose();
  }

  Future<void> _loadFeaturedRecipes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _catalogService.getRecipes(
        category: 'Semua',
        page: 1,
        limit: 12,
      );

      if (!mounted) {
        return;
      }

      final recipesWithImage = result.recipes
          .where(
            (recipe) =>
                recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty,
          )
          .toList();

      final recipesWithoutImage = result.recipes
          .where(
            (recipe) =>
                recipe.imageUrl == null || recipe.imageUrl!.trim().isEmpty,
          )
          .toList();

      final orderedRecipes = [...recipesWithImage, ...recipesWithoutImage];

      setState(() {
        _featuredRecipes = orderedRecipes.take(6).toList();

        _errorMessage = null;
      });
    } on RecipeCatalogException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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

  void _openMealPlanner() {
    final isPremium = SubscriptionController.instance.isPremium;

    if (isPremium) {
      context.push('/meal-planner');

      return;
    }

    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.calendar_month_rounded,
            size: 42,
            color: colors.primary,
          ),
          title: const Text('Fitur Premium'),
          content: const Text(
            'Meal Planner tersedia untuk pengguna '
            'RacikAI Premium.',
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
              child: const Text('Lihat Premium'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(milliseconds: 1000),
        content: Text('Belum ada notifikasi baru.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadFeaturedRecipes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RacikAI',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: IconButton(
                          tooltip: 'Notifikasi',
                          onPressed: _showNotificationMessage,
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: widget.onSearchTap,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Cari resep...',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _HomeHeroCard(
                    onMealPlannerTap: _openMealPlanner,
                    onIngredientTap: () {
                      context.push('/ingredients');
                    },
                  ),

                  const SizedBox(height: 30),

                  _SectionHeader(
                    title: 'Kategori',
                    actionLabel: 'Lihat Semua',
                    onTap: widget.onSearchTap,
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final category = _categories[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: widget.onSearchTap,
                          child: SizedBox(
                            width: 72,
                            child: Column(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.outlineVariant,
                                    ),
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  category['name'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  _SectionHeader(
                    title: 'Pilihan RacikAI',
                    actionLabel: 'Lihat Semua',
                    onTap: widget.onSearchTap,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Jelajahi beberapa resep dari '
                    'koleksi RacikAI.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildFeaturedSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (_errorMessage != null) {
      return _FeaturedError(
        message: _errorMessage!,
        onRetry: _loadFeaturedRecipes,
      );
    }

    if (_featuredRecipes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 38,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada resep untuk ditampilkan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 286,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _featuredRecipes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final recipe = _featuredRecipes[index];

          return _HomeRecipeCard(
            recipe: recipe,
            onTap: () {
              _openRecipe(recipe);
            },
          );
        },
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  final VoidCallback onMealPlannerTap;
  final VoidCallback onIngredientTap;

  const _HomeHeroCard({
    required this.onMealPlannerTap,
    required this.onIngredientTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.auto_awesome, color: colors.primary),
          ),

          const SizedBox(height: 18),

          Text(
            'Punya bahan di rumah?',
            style: TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Beritahu RacikAI bahan yang kamu punya '
            'dan temukan resep yang cocok untuk dibuat.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.onPrimaryContainer.withValues(alpha: 0.78),
            ),
          ),

          const SizedBox(height: 18),

          FilledButton.icon(
            onPressed: onIngredientTap,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Cari dari Bahan'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.surface,
              foregroundColor: colors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onMealPlannerTap,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meal Planner',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rencanakan menu untuk 7 hari',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _HomeRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      child: Material(
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
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _HomeRecipeImage(imageUrl: recipe.imageUrl),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: BlocBuilder<FavoriteCubit, FavoriteState>(
                          buildWhen: (previous, current) {
                            return previous.favoriteIds != current.favoriteIds;
                          },
                          builder: (context, state) {
                            final isFavorite = state.isFavorite(recipe.id);

                            return Material(
                              color: colors.surface.withValues(alpha: 0.94),
                              shape: const CircleBorder(),
                              elevation: 2,
                              clipBehavior: Clip.antiAlias,
                              child: IconButton(
                                tooltip: isFavorite
                                    ? 'Hapus dari tersimpan'
                                    : 'Simpan resep',
                                onPressed: () {
                                  context
                                      .read<FavoriteCubit>()
                                      .toggleBackendFavorite(
                                        SavedRecipe.fromCatalogRecipe(recipe),
                                      );
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
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
      ),
    );
  }
}

class _HomeRecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _HomeRecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
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
              width: 26,
              height: 26,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded, size: 42, color: colors.primary),
    );
  }
}

class _FeaturedError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FeaturedError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 38, color: colors.error),

          const SizedBox(height: 10),

          Text(
            'Resep pilihan gagal dimuat',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
