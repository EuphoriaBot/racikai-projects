import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/meal_planner_controller.dart';
import '../features/recipe/data/models/catalog_recipe.dart';
import '../services/recipe_catalog_service.dart';
import 'ai_recipe_detail_screen.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = MealPlannerController.instance;
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Meal Planner',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: planner,
            builder: (context, _) {
              return IconButton(
                tooltip: 'Hapus semua',
                onPressed: planner.hasMeals
                    ? () {
                        _showClearDialog(context);
                      }
                    : null,
                icon: const Icon(Icons.delete_outline_rounded),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: planner,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _PlannerHeader(colors: colors),

              const SizedBox(height: 26),

              ...planner.days.map((day) {
                final recipe = planner.recipeForDay(day);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealDayCard(day: day, recipe: recipe),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          title: const Text('Hapus Meal Plan?'),
          content: const Text(
            'Semua menu yang sudah dipilih '
            'untuk minggu ini akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                MealPlannerController.instance.clearPlan();

                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class _PlannerHeader extends StatelessWidget {
  final ColorScheme colors;

  const _PlannerHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, size: 34, color: colors.primary),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rencana makan mingguan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Pilih satu resep untuk setiap hari '
                  'agar menu mingguan lebih teratur.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colors.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealDayCard extends StatelessWidget {
  final String day;
  final CatalogRecipe? recipe;

  const _MealDayCard({required this.day, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: recipe == null
          ? _EmptyDay(day: day)
          : _FilledDay(day: day, recipe: recipe!),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final String day;

  const _EmptyDay({required this.day});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _showRecipePicker(context, day);
      },
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_rounded, size: 19, color: colors.primary),

                    const SizedBox(width: 7),

                    Text(
                      'Pilih resep',
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledDay extends StatelessWidget {
  final String day;
  final CatalogRecipe recipe;

  const _FilledDay({required this.day, required this.recipe});

  void _openRecipe(BuildContext context) {
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

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              day,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _openRecipe(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      _RecipeThumbnail(imageUrl: recipe.imageUrl, size: 56),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            const SizedBox(height: 5),

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
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
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
          ),

          PopupMenuButton<String>(
            tooltip: 'Opsi',
            iconColor: colors.onSurfaceVariant,
            onSelected: (value) {
              if (value == 'change') {
                _showRecipePicker(context, day);
              }

              if (value == 'remove') {
                MealPlannerController.instance.removeRecipeFromDay(day);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'change',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded),
                    SizedBox(width: 10),
                    Text('Ganti resep'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded),
                    SizedBox(width: 10),
                    Text('Hapus'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _showRecipePicker(BuildContext context, String day) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (_) {
      return _RecipePickerSheet(day: day);
    },
  );
}

class _RecipePickerSheet extends StatefulWidget {
  final String day;

  const _RecipePickerSheet({required this.day});

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  final RecipeCatalogService _catalogService = RecipeCatalogService();

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  List<CatalogRecipe> _recipes = [];

  String _query = '';

  String? _errorMessage;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;

  int _page = 1;
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
    _query = value;

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadRecipes(reset: true);
    });
  }

  Future<void> _loadRecipes({required bool reset}) async {
    if (reset) {
      _requestVersion++;

      setState(() {
        _page = 1;
        _recipes = [];
        _hasMore = false;
        _errorMessage = null;
        _isLoading = true;
        _isLoadingMore = false;
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
        query: _query,
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

  void _selectRecipe(CatalogRecipe recipe) {
    MealPlannerController.instance.setRecipeForDay(widget.day, recipe);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final height = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: height * 0.82,
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pilih menu ${widget.day}',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();

                          _query = '';

                          _loadRecipes(reset: true);
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(child: _buildContent(colors)),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _recipes.isEmpty) {
      return _PickerError(
        message: _errorMessage!,
        onRetry: () {
          _loadRecipes(reset: true);
        },
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: colors.onSurfaceVariant,
              ),

              const SizedBox(height: 12),

              Text(
                'Resep tidak ditemukan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Coba gunakan kata kunci lain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: _recipes.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _recipes.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  : OutlinedButton.icon(
                      onPressed: () {
                        _loadRecipes(reset: false);
                      },
                      icon: const Icon(Icons.expand_more_rounded),
                      label: const Text('Muat lebih banyak'),
                    ),
            ),
          );
        }

        final recipe = _recipes[index];

        return Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _selectRecipe(recipe);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  _RecipeThumbnail(imageUrl: recipe.imageUrl, size: 62),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        const SizedBox(height: 6),

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
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Icon(Icons.add_circle_outline_rounded, color: colors.primary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecipeThumbnail extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _RecipeThumbnail({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: SizedBox(
        width: size,
        height: size,
        child: hasImage
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
      color: colors.primaryContainer,
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_rounded, size: 26, color: colors.primary),
    );
  }
}

class _PickerError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PickerError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: colors.error),

            const SizedBox(height: 14),

            Text(
              'Gagal Memuat Resep',
              style: TextStyle(
                fontSize: 17,
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

            const SizedBox(height: 18),

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
