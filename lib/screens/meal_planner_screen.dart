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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rencana makan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          AnimatedBuilder(
            animation: planner,
            builder: (context, _) {
              if (!planner.hasMeals) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Hapus semua rencana',
                onPressed: () {
                  _showClearDialog(context);
                },
                icon: const Icon(Icons.delete_outline_rounded),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedBuilder(
        animation: planner,
        builder: (context, _) {
          final filledDays = planner.days.where((day) {
            return planner.recipeForDay(day) != null;
          }).length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  12,
                  isWide ? 24 : 16,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlannerOverview(
                          filledDays: filledDays,
                          totalDays: planner.days.length,
                          isWide: isWide,
                        ),

                        const SizedBox(height: 28),

                        if (isWide)
                          _DesktopPlannerGrid(
                            planner: planner,
                            availableWidth: constraints.maxWidth,
                          )
                        else
                          _MobilePlannerList(planner: planner),
                      ],
                    ),
                  ),
                ),
              );
            },
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
          icon: Icon(Icons.delete_outline_rounded, color: colors.error),
          title: const Text('Hapus semua rencana?'),
          content: const Text(
            'Semua menu yang sudah dipilih untuk minggu ini '
            'akan dihapus.',
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
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              child: const Text('Hapus semua'),
            ),
          ],
        );
      },
    );
  }
}

class _PlannerOverview extends StatelessWidget {
  final int filledDays;
  final int totalDays;
  final bool isWide;

  const _PlannerOverview({
    required this.filledDays,
    required this.totalDays,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progress = totalDays == 0 ? 0.0 : filledDays / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rencana Mingguan',
          style: TextStyle(
            fontSize: isWide ? 32 : 27,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Susun menu untuk seminggu agar pilihan makanan '
          'lebih terencana.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 22),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      Icons.calendar_today_outlined,
                      size: 21,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minggu ini',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          filledDays == 0
                              ? 'Belum ada menu yang direncanakan'
                              : '$filledDays dari $totalDays hari terisi',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '$filledDays/$totalDays',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: colors.surfaceContainerHighest,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobilePlannerList extends StatelessWidget {
  final MealPlannerController planner;

  const _MobilePlannerList({required this.planner});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < planner.days.length; i++) ...[
          _MobileDayCard(
            day: planner.days[i],
            recipe: planner.recipeForDay(planner.days[i]),
          ),
          if (i != planner.days.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MobileDayCard extends StatelessWidget {
  final String day;
  final CatalogRecipe? recipe;

  const _MobileDayCard({required this.day, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (recipe == null) {
      return Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _showRecipePicker(context, day);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.add_rounded, color: colors.primary),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Belum ada menu',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(width: 4),

                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openRecipe(context, recipe!);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _RecipeThumbnail(imageUrl: recipe!.imageUrl, size: 76),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      recipe!.title,
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
                        Text(
                          '${recipe!.ingredientCount} bahan',
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

              _DayOptionsButton(day: day),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopPlannerGrid extends StatelessWidget {
  final MealPlannerController planner;
  final double availableWidth;

  const _DesktopPlannerGrid({
    required this.planner,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    final columns = availableWidth >= 1050 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: planner.days.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 265,
      ),
      itemBuilder: (context, index) {
        final day = planner.days[index];
        final recipe = planner.recipeForDay(day);

        return _DesktopDayCard(day: day, recipe: recipe);
      },
    );
  }
}

class _DesktopDayCard extends StatelessWidget {
  final String day;
  final CatalogRecipe? recipe;

  const _DesktopDayCard({required this.day, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (recipe == null) {
      return Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _showRecipePicker(context, day);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                const Spacer(),

                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 27,
                      color: colors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                Center(
                  child: Text(
                    'Tambah menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Center(
                  child: Text(
                    'Pilih resep untuk hari $day',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openRecipe(context, recipe!);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 142,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RecipeImage(imageUrl: recipe!.imageUrl),

                  Positioned(
                    top: 11,
                    left: 11,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 7,
                    right: 5,
                    child: _DayOptionsButton(day: day, lightBackground: true),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
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
                          '${recipe!.ingredientCount} bahan',
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
            ),
          ],
        ),
      ),
    );
  }
}

class _DayOptionsButton extends StatelessWidget {
  final String day;
  final bool lightBackground;

  const _DayOptionsButton({required this.day, this.lightBackground = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Opsi',
      color: colors.surface,
      icon: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: lightBackground
              ? colors.surface.withValues(alpha: 0.94)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: colors.onSurfaceVariant,
        ),
      ),
      onSelected: (value) {
        if (value == 'change') {
          _showRecipePicker(context, day);
        }

        if (value == 'remove') {
          MealPlannerController.instance.removeRecipeFromDay(day);
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'change',
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, size: 20),
                SizedBox(width: 10),
                Text('Ganti resep'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded, size: 20),
                SizedBox(width: 10),
                Text('Hapus'),
              ],
            ),
          ),
        ];
      },
    );
  }
}

void _openRecipe(BuildContext context, CatalogRecipe recipe) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AiRecipeDetailScreen(
        recipe: recipe.toAiRecipe(),
        isAiRecommendation: false,
      ),
    ),
  );
}

void _showRecipePicker(BuildContext context, String day) {
  final width = MediaQuery.sizeOf(context).width;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    constraints: BoxConstraints(maxWidth: width >= 700 ? 720 : double.infinity),
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
    setState(() {
      _query = value;
    });

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
      height: height * 0.86,
      child: Column(
        children: [
          const SizedBox(height: 10),

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih menu ${widget.day}',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cari resep yang ingin dimasukkan '
                        'ke rencana makan.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari resep atau bahan...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();

                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded),
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
                size: 46,
                color: colors.onSurfaceVariant,
              ),

              const SizedBox(height: 13),

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
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
      itemCount: _recipes.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _recipes.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: _isLoadingMore
                  ? const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
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

        return _PickerRecipeTile(
          recipe: recipe,
          onTap: () {
            _selectRecipe(recipe);
          },
        );
      },
    );
  }
}

class _PickerRecipeTile extends StatelessWidget {
  final CatalogRecipe recipe;
  final VoidCallback onTap;

  const _PickerRecipeTile({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _RecipeThumbnail(imageUrl: recipe.imageUrl, size: 64),

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

              const SizedBox(width: 10),

              Icon(Icons.add_circle_rounded, color: colors.primary),
            ],
          ),
        ),
      ),
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
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.restaurant_outlined, size: 25, color: colors.primary),
    );
  }
}

class _RecipeImage extends StatelessWidget {
  final String? imageUrl;

  const _RecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    if (!hasImage) {
      return _placeholder(colors);
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) {
        return _placeholder(colors);
      },
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 38,
        color: colors.primary.withValues(alpha: 0.72),
      ),
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
            Icon(Icons.cloud_off_outlined, size: 46, color: colors.error),

            const SizedBox(height: 14),

            Text(
              'Gagal memuat resep',
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
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 18),

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
