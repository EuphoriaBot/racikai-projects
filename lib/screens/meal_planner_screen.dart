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

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meal Planner',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus semua',
            onPressed: () {
              _showClearDialog(context);
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: planner,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8D5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 34,
                      color: Color(0xFFE8752E),
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rencana makan mingguan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Pilih satu resep untuk setiap hari agar menu mingguan lebih teratur.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Color(0xFF666666),
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
                backgroundColor: const Color(0xFFE8752E),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEEEE)),
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
                  color: const Color(0xFFFFF7F0),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 19, color: Color(0xFFE8752E)),

                    SizedBox(width: 7),

                    Text(
                      'Pilih resep',
                      style: TextStyle(
                        color: Color(0xFFE8752E),
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
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              day,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),

          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D5),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    recipe.duration,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
          ),

          PopupMenuButton<String>(
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
    backgroundColor: const Color(0xFFFFFBF7),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (sheetContext) {
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
                  color: const Color(0xFFD0D0D0),
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
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
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
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFEEEEEE)),
                      ),
                      leading: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE8D5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                      title: Text(
                        recipe.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text('${recipe.category} • ${recipe.duration}'),
                      trailing: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFE8752E),
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
