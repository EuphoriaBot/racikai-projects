import 'package:flutter/material.dart';

import '../data/dummy_recipes.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class IngredientResultScreen extends StatelessWidget {
  final List<String> selectedIngredients;

  const IngredientResultScreen({super.key, required this.selectedIngredients});

  bool ingredientMatches(String recipeIngredient, String selectedIngredient) {
    final recipeText = recipeIngredient.toLowerCase();

    final selectedText = selectedIngredient.toLowerCase();

    return recipeText.contains(selectedText) ||
        selectedText.contains(recipeText);
  }

  int calculateMatchedIngredients(Recipe recipe) {
    int matchCount = 0;

    for (final recipeIngredient in recipe.ingredients) {
      final matched = selectedIngredients.any((selectedIngredient) {
        return ingredientMatches(recipeIngredient, selectedIngredient);
      });

      if (matched) {
        matchCount++;
      }
    }

    return matchCount;
  }

  double calculateMatchPercentage(Recipe recipe) {
    if (recipe.ingredients.isEmpty) {
      return 0;
    }

    final matched = calculateMatchedIngredients(recipe);

    return matched / recipe.ingredients.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    final matchedRecipes = dummyRecipes
        .where((recipe) => calculateMatchedIngredients(recipe) > 0)
        .toList();

    matchedRecipes.sort((a, b) {
      return calculateMatchPercentage(b).compareTo(calculateMatchPercentage(a));
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Resep yang Cocok',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: matchedRecipes.isEmpty
          ? const _NoResult()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const Text(
                  'Berdasarkan bahanmu',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${selectedIngredients.length} bahan dipilih • ${matchedRecipes.length} resep ditemukan',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: selectedIngredients.map((ingredient) {
                    return Chip(
                      label: Text(ingredient),
                      backgroundColor: const Color(0xFFFFE8D5),
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                        color: Color(0xFFE8752E),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 26),

                ...matchedRecipes.map((recipe) {
                  final matched = calculateMatchedIngredients(recipe);

                  final percentage = calculateMatchPercentage(recipe).round();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _IngredientRecipeCard(
                      recipe: recipe,
                      matchPercentage: percentage,
                      matchedIngredients: matched,
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _IngredientRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int matchPercentage;
  final int matchedIngredients;

  const _IngredientRecipeCard({
    required this.recipe,
    required this.matchPercentage,
    required this.matchedIngredients,
  });

  Color getMatchColor() {
    if (matchPercentage >= 70) {
      return const Color(0xFF2E9B64);
    }

    if (matchPercentage >= 40) {
      return const Color(0xFFE8752E);
    }

    return const Color(0xFF888888);
  }

  @override
  Widget build(BuildContext context) {
    final matchColor = getMatchColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8D5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 44)),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: matchColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '$matchPercentage% cocok',
                            style: TextStyle(
                              color: matchColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$matchedIngredients dari ${recipe.ingredients.length} bahan tersedia',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 15,
                          color: Color(0xFFE8752E),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          recipe.duration,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: Color(0xFFAAAAAA),
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

class _NoResult extends StatelessWidget {
  const _NoResult();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 68,
              color: Color(0xFFCCCCCC),
            ),
            SizedBox(height: 18),
            Text(
              'Belum ada resep yang cocok',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Coba pilih bahan lain atau tambahkan lebih banyak bahan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
