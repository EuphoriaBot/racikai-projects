import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';
import 'dart:math';

import '../core/router/recipe_detail_route_args.dart';
import '../features/favorite/data/models/saved_recipe.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';
import '../features/recipe/data/models/catalog_recipe.dart';
import '../services/recipe_catalog_service.dart';
import '../widgets/recipe_search_bar.dart';
import '../widgets/recipe_hero_header.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({super.key, required this.onSearchTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeCatalogService _catalogService = RecipeCatalogService();

  final List<Map<String, Object>> _categories = const [
    {'name': 'Ayam', 'icon': Icons.set_meal_outlined},
    {'name': 'Daging', 'icon': Icons.restaurant_outlined},
    {'name': 'Sayur', 'icon': Icons.eco_outlined},
    {'name': 'Pasta', 'icon': Icons.ramen_dining_outlined},
    {'name': 'Dessert', 'icon': Icons.cake_outlined},
  ];

  List<CatalogRecipe> _featuredRecipes = [];

  List<CatalogRecipe> _carouselRecipes = [];

  String? _homeHeroImageUrl;

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadFeaturedRecipes();
    _loadRandomCarouselRecipes();
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

      if (!mounted) return;

      final recipesWithImage = result.recipes.where((recipe) {
        final image = recipe.imageUrl;
        return image != null && image.trim().isNotEmpty;
      }).toList();

      final recipesWithoutImage = result.recipes.where((recipe) {
        final image = recipe.imageUrl;
        return image == null || image.trim().isEmpty;
      }).toList();

      final orderedRecipes = [...recipesWithImage, ...recipesWithoutImage];

      var heroCandidates = recipesWithImage.where((recipe) {
        return !recipe.title.toLowerCase().contains('pasta');
      }).toList();

      if (heroCandidates.isEmpty) {
        heroCandidates = recipesWithImage;
      }

      try {
        const heroPageSize = 24;

        final totalPages = (result.total + heroPageSize - 1) ~/ heroPageSize;

        final randomPage = totalPages > 0
            ? 1 + Random().nextInt(totalPages)
            : 1;

        final randomResult = await _catalogService.getRecipes(
          category: 'Semua',
          page: randomPage,
          limit: heroPageSize,
        );

        final randomCandidates = randomResult.recipes.where((recipe) {
          final image = recipe.imageUrl;

          return image != null &&
              image.trim().isNotEmpty &&
              !recipe.title.toLowerCase().contains('pasta');
        }).toList();

        if (randomCandidates.isNotEmpty) {
          heroCandidates = randomCandidates;
        }
      } catch (_) {}

      if (!mounted) return;

      final differentCandidates = heroCandidates.where((recipe) {
        return recipe.imageUrl != _homeHeroImageUrl;
      }).toList();

      final imageChoices = differentCandidates.isNotEmpty
          ? differentCandidates
          : heroCandidates;

      imageChoices.shuffle();

      final selectedImageUrl = imageChoices.isNotEmpty
          ? imageChoices.first.imageUrl
          : _homeHeroImageUrl;

      setState(() {
        _featuredRecipes = orderedRecipes.take(6).toList();

        _homeHeroImageUrl = selectedImageUrl;

        _errorMessage = null;
      });
    } on RecipeCatalogException catch (error) {
      if (!mounted) return;

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

  Future<void> _loadRandomCarouselRecipes() async {
    try {
      const pageSize = 24;
      final random = Random();

      final firstResult = await _catalogService.getRecipes(
        category: 'Semua',
        page: 1,
        limit: pageSize,
      );

      if (!mounted || firstResult.total <= 0) return;

      final totalPages = (firstResult.total + pageSize - 1) ~/ pageSize;

      final selectedRecipes = <CatalogRecipe>[];
      final selectedIds = <Object>{};
      final usedPages = <int>{};

      for (
        int attempt = 0;
        attempt < 5 && selectedRecipes.length < 5;
        attempt++
      ) {
        final page = 1 + random.nextInt(totalPages);

        if (!usedPages.add(page)) {
          continue;
        }

        final result = page == 1
            ? firstResult
            : await _catalogService.getRecipes(
                category: 'Semua',
                page: page,
                limit: pageSize,
              );

        if (!mounted) return;

        final candidates = result.recipes.where((recipe) {
          final image = recipe.imageUrl;

          return image != null && image.trim().isNotEmpty;
        }).toList();

        candidates.shuffle(random);

        var addedFromPage = 0;

        for (final recipe in candidates) {
          if (selectedIds.add(recipe.id)) {
            selectedRecipes.add(recipe);
            addedFromPage++;
          }

          if (selectedRecipes.length == 5 || addedFromPage == 2) {
            break;
          }
        }
      }

      if (!mounted) return;

      if (selectedRecipes.length == 5) {
        setState(() {
          _carouselRecipes = selectedRecipes;
        });
      }
    } catch (_) {}
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

  void _openIngredientFinder() {
    context.push('/ingredients');
  }

  void _openMealPlanner() {
    context.push('/meal-planner');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadFeaturedRecipes(),
            _loadRandomCarouselRecipes(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeroHeader(
                onSearchTap: widget.onSearchTap,
                imageUrl: _homeHeroImageUrl,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle(title: 'Masak lebih mudah'),

                        const SizedBox(height: 14),

                        _QuickActions(
                          onIngredientTap: _openIngredientFinder,
                          onMealPlannerTap: _openMealPlanner,
                        ),

                        const SizedBox(height: 32),

                        _SectionTitle(
                          title: 'Kategori',
                          actionLabel: 'Lihat semua',
                          onActionTap: widget.onSearchTap,
                        ),

                        const SizedBox(height: 14),

                        _CategoryList(
                          categories: _categories,
                          onCategoryTap: widget.onSearchTap,
                        ),

                        const SizedBox(height: 34),

                        _buildRecipeContent(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return SizedBox(
        height: 320,
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
      return _EmptyRecipes(onRetry: _loadFeaturedRecipes);
    }

    final hasRandomCarousel = _carouselRecipes.length == 5;

    final carouselRecipes = hasRandomCarousel
        ? _carouselRecipes
        : _featuredRecipes.take(5).toList();

    final otherRecipes = hasRandomCarousel
        ? _featuredRecipes
        : _featuredRecipes.skip(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Inspirasi hari ini',
          actionLabel: 'Lihat semua',
          onActionTap: widget.onSearchTap,
        ),

        const SizedBox(height: 6),

        Text(
          'Temukan sesuatu yang menarik '
          'untuk dimasak hari ini.',
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        _FeaturedRecipeCarousel(
          recipes: carouselRecipes,
          onRecipeTap: _openRecipe,
        ),

        if (otherRecipes.isNotEmpty) ...[
          const SizedBox(height: 32),

          _SectionTitle(
            title: 'Resep lainnya',
            actionLabel: 'Jelajahi',
            onActionTap: widget.onSearchTap,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: otherRecipes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final recipe = otherRecipes[index];

                return _CompactRecipeCard(
                  recipe: recipe,
                  onTap: () {
                    _openRecipe(recipe);
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeHeroHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final String? imageUrl;

  const _HomeHeroHeader({required this.onSearchTap, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return RecipeHeroHeader(
      firstLine: 'Bahan biasa',
      secondLine: 'Rasa istimewa',
      subtitle: 'Inspirasi masak dimulai\ndari isi dapurmu',
      imageUrl: imageUrl,
      searchBar: RecipeSearchBar(
        readOnly: true,
        heroStyle: true,
        onTap: onSearchTap,
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onIngredientTap;
  final VoidCallback onMealPlannerTap;

  const _QuickActions({
    required this.onIngredientTap,
    required this.onMealPlannerTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 650;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: isWide ? 112 : 156,
                child: _QuickActionCard(
                  icon: Icons.kitchen_outlined,
                  title: 'Dari bahan',
                  subtitle: 'Cari resep dari isi dapurmu',
                  backgroundColor: colors.primaryContainer,
                  iconBackgroundColor: colors.surface.withValues(alpha: 0.55),
                  iconColor: colors.primary,
                  foregroundColor: colors.onPrimaryContainer,
                  horizontal: isWide,
                  onTap: onIngredientTap,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: isWide ? 112 : 156,
                child: _QuickActionCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Rencana makan',
                  subtitle: 'Susun menu untuk 7 hari',
                  backgroundColor: colors.secondaryContainer,
                  iconBackgroundColor: colors.surface.withValues(alpha: 0.55),
                  iconColor: colors.secondary,
                  foregroundColor: colors.onSecondaryContainer,
                  horizontal: isWide,
                  onTap: onMealPlannerTap,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color foregroundColor;
  final bool horizontal;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.foregroundColor,
    required this.horizontal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: horizontal ? _buildHorizontal() : _buildMobile(),
      ),
    );
  }

  Widget _buildMobile() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ActionIcon(
                icon: icon,
                backgroundColor: iconBackgroundColor,
                iconColor: iconColor,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 19,
                color: foregroundColor.withValues(alpha: 0.65),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: foregroundColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.35,
              color: foregroundColor.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          _ActionIcon(
            icon: icon,
            backgroundColor: iconBackgroundColor,
            iconColor: iconColor,
            size: 46,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: foregroundColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: foregroundColor.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: foregroundColor.withValues(alpha: 0.65),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const _ActionIcon({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 21, color: iconColor),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<Map<String, Object>> categories;

  final VoidCallback onCategoryTap;

  const _CategoryList({required this.categories, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 43,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = categories[index];

          return Material(
            color: colors.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onCategoryTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 17,
                      color: colors.primary,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedRecipeCarousel extends StatefulWidget {
  final List<CatalogRecipe> recipes;
  final ValueChanged<CatalogRecipe> onRecipeTap;

  const _FeaturedRecipeCarousel({
    required this.recipes,
    required this.onRecipeTap,
  });

  @override
  State<_FeaturedRecipeCarousel> createState() =>
      _FeaturedRecipeCarouselState();
}

class _FeaturedRecipeCarouselState extends State<_FeaturedRecipeCarousel> {
  late final PageController _pageController;

  Timer? _slideTimer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.recipes.length * 1000);

    _scheduleNextSlide();
  }

  void _scheduleNextSlide() {
    _slideTimer?.cancel();

    if (widget.recipes.length <= 1) return;

    _slideTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _FeaturedRecipeCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.recipes.length != widget.recipes.length) {
      _activeIndex = 0;
      _scheduleNextSlide();
    }
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (widget.recipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            physics: widget.recipes.length > 1
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: widget.recipes.length > 1 ? null : 1,
            onPageChanged: (page) {
              setState(() {
                _activeIndex = page % widget.recipes.length;
              });

              _scheduleNextSlide();
            },
            itemBuilder: (context, index) {
              final recipe = widget.recipes[index % widget.recipes.length];

              return _FeaturedRecipeCard(
                recipe: recipe,
                onTap: () {
                  widget.onRecipeTap(recipe);
                },
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.recipes.length, (index) {
            final isActive = index == _activeIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(100),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _FeaturedRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final isWide = MediaQuery.sizeOf(context).width >= 600;

    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESEP PILIHAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Text(
                      recipe.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: colors.onSurface,
                      ),
                    ),

                    const Spacer(),

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

                    const SizedBox(height: 9),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lihat resep',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                width: isWide ? 170 : 108,
                height: 152,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _RecipeImage(imageUrl: recipe.imageUrl),

                      Positioned(
                        top: 7,
                        right: 7,
                        child: _FavoriteRecipeButton(recipe: recipe),
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

class _CompactRecipeCard extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _CompactRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 180,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 180,
                  height: 135,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _RecipeImage(imageUrl: recipe.imageUrl),

                      Positioned(
                        top: 9,
                        right: 9,
                        child: _FavoriteRecipeButton(recipe: recipe),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 11),

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
                        color: colors.onSurfaceVariant,
                      ),
                    ),
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

class _FavoriteRecipeButton extends StatelessWidget {
  final CatalogRecipe recipe;
  final bool large;

  const _FavoriteRecipeButton({required this.recipe, this.large = false});

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
              width: large ? 42 : 36,
              height: large ? 42 : 36,
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: large ? 21 : 19,
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
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: colors.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 25,
              height: 25,
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
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 40,
        color: colors.primary.withValues(alpha: 0.75),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _SectionTitle({
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
              color: colors.onSurface,
            ),
          ),
        ),

        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
      ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, size: 38, color: colors.error),

          const SizedBox(height: 12),

          Text(
            'Resep gagal dimuat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 16),

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

class _EmptyRecipes extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyRecipes({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 40,
            color: colors.onSurfaceVariant,
          ),

          const SizedBox(height: 12),

          Text(
            'Belum ada resep',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Coba muat kembali koleksi resep.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Muat ulang'),
          ),
        ],
      ),
    );
  }
}
