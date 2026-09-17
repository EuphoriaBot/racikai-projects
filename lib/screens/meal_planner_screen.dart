import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/meal_planner_controller.dart';
import '../core/di/service_locator.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeCubit>()..loadRecipes(),
      child: const _MealPlannerContent(),
    );
  }
}

class _MealPlannerContent extends StatelessWidget {
  const _MealPlannerContent();

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
          IconButton(
            tooltip: 'Hapus semua',
            onPressed: () {
              _showClearDialog(context);
            },
            icon: Icon(Icons.delete_outline, color: colors.onSurfaceVariant),
          ),
        ],
      ),

      body: BlocBuilder<RecipeCubit, RecipeState>(
        builder: (context, recipeState) {
          if (recipeState is RecipeInitial || recipeState is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (recipeState is RecipeError) {
            return _RecipeError(
              message: recipeState.message,
              onRetry: () {
                context.read<RecipeCubit>().loadRecipes();
              },
            );
          }

          if (recipeState is RecipeLoaded) {
            return AnimatedBuilder(
              animation: planner,
              builder: (context, _) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 34,
                            color: colors.primary,
                          ),

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
                                    color: colors.onPrimaryContainer.withValues(
                                      alpha: 0.75,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    ...planner.days.map((day) {
                      final recipeId = planner.recipeIdForDay(day);

                      final recipe = _findRecipeById(
                        recipeState.recipes,
                        recipeId,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MealDayCard(
                          day: day,
                          recipe: recipe,
                          recipes: recipeState.recipes,
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
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

RecipeEntity? _findRecipeById(List<RecipeEntity> recipes, int? recipeId) {
  if (recipeId == null) {
    return null;
  }

  for (final recipe in recipes) {
    if (recipe.id == recipeId) {
      return recipe;
    }
  }

  return null;
}

class _MealDayCard extends StatelessWidget {
  final String day;
  final RecipeEntity? recipe;
  final List<RecipeEntity> recipes;

  const _MealDayCard({
    required this.day,
    required this.recipe,
    required this.recipes,
  });

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
          ? _EmptyDay(day: day, recipes: recipes)
          : _FilledDay(day: day, recipe: recipe!, recipes: recipes),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final String day;
  final List<RecipeEntity> recipes;

  const _EmptyDay({required this.day, required this.recipes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _showRecipePicker(context, day, recipes);
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
                    Icon(Icons.add, size: 19, color: colors.primary),

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
  final RecipeEntity recipe;
  final List<RecipeEntity> recipes;

  const _FilledDay({
    required this.day,
    required this.recipe,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(15),
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

          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(recipe.emoji, style: const TextStyle(fontSize: 28)),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: InkWell(
              onTap: () {
                context.push('/recipe/${recipe.id}');
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    recipe.duration,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          PopupMenuButton<String>(
            iconColor: colors.onSurfaceVariant,
            onSelected: (value) {
              if (value == 'change') {
                _showRecipePicker(context, day, recipes);
              }

              if (value == 'remove') {
                MealPlannerController.instance.removeRecipeFromDay(day);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'change', child: Text('Ganti resep')),
              const PopupMenuItem(value: 'remove', child: Text('Hapus')),
            ],
          ),
        ],
      ),
    );
  }
}

void _showRecipePicker(
  BuildContext context,
  String day,
  List<RecipeEntity> recipes,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;

      return SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.72,
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pilih menu $day',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];

                    return ListTile(
                      onTap: () {
                        MealPlannerController.instance.setRecipeForDay(
                          day,
                          recipe.id,
                        );

                        Navigator.pop(sheetContext);
                      },

                      tileColor: colors.surface,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colors.outlineVariant),
                      ),

                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),

                      title: Text(
                        recipe.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),

                      subtitle: Text(
                        '${recipe.category} • '
                        '${recipe.duration}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),

                      trailing: Icon(
                        Icons.add_circle_outline,
                        color: colors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
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
            Icon(Icons.error_outline_rounded, size: 64, color: colors.error),

            const SizedBox(height: 16),

            Text(
              'Gagal Memuat Resep',
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
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
