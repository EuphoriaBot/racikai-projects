import 'package:flutter/material.dart';

import '../controllers/meal_planner_controller.dart';
import '../data/dummy_recipes.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

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
          IconButton(
            tooltip: 'Hapus semua',
            onPressed: () {
              _showClearDialog(context);
            },
            icon: Icon(Icons.delete_outline, color: colors.onSurfaceVariant),
          ),
        ],
      ),

      body: AnimatedBuilder(
        animation: planner,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // HEADER CARD
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
                            'Pilih satu resep untuk setiap hari agar menu mingguan lebih teratur.',
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

              // DAYS
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
            'Semua menu yang sudah dipilih untuk minggu ini akan dihapus.',
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

class _MealDayCard extends StatelessWidget {
  final String day;
  final Recipe? recipe;

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
  final Recipe recipe;

  const _FilledDay({required this.day, required this.recipe});

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
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
                _showRecipePicker(context, day);
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

void _showRecipePicker(BuildContext context, String day) {
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
                  itemCount: dummyRecipes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final recipe = dummyRecipes[index];

                    return ListTile(
                      onTap: () {
                        MealPlannerController.instance.setRecipeForDay(
                          day,
                          recipe,
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
                        '${recipe.category} • ${recipe.duration}',
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
