import 'package:flutter/material.dart';

import '../widgets/recipe_card.dart';
import '../data/dummy_recipes.dart';
import 'recipe_detail_screen.dart';
import 'ingredient_finder_screen.dart';
import '../controllers/subscription_controller.dart';
import 'meal_planner_screen.dart';
import 'premium_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSearchTap;

  const HomeScreen({super.key, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final categories = [
      {'name': 'Ayam', 'icon': Icons.set_meal},
      {'name': 'Daging', 'icon': Icons.restaurant},
      {'name': 'Sayur', 'icon': Icons.eco},
      {'name': 'Pasta', 'icon': Icons.ramen_dining},
      {'name': 'Dessert', 'icon': Icons.cake_outlined},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Text(
              'Selamat datang 👋',
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),

            const SizedBox(height: 4),

            Text(
              'Mau masak apa hari ini?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 22),

            // SEARCH BAR
            InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: colors.onSurfaceVariant),
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

            // INGREDIENT FINDER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.auto_awesome, color: colors.onPrimary),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Punya bahan di rumah?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // MEAL PLANNER
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        final isPremium =
                            SubscriptionController.instance.isPremium;

                        if (isPremium) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MealPlannerScreen(),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                icon: Icon(
                                  Icons.calendar_month,
                                  size: 42,
                                  color: colors.primary,
                                ),
                                title: const Text('Fitur Premium'),
                                content: const Text(
                                  'Meal Planner tersedia untuk pengguna RacikAI Premium.',
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

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PremiumScreen(),
                                        ),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colors.primary,
                                      foregroundColor: colors.onPrimary,
                                    ),
                                    child: const Text('Lihat Premium'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: colors.primary,
                                ),
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
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: colors.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Beritahu RacikAI bahan yang kamu punya dan temukan resep yang cocok untuk dibuat.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colors.onPrimaryContainer.withValues(alpha: 0.75),
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IngredientFinderScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Cari dari Bahan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CATEGORY TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: onSearchTap,
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // CATEGORY LIST
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: colors.primary,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // RECOMMENDATION TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rekomendasi untukmu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: onSearchTap,
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // RECOMMENDATION RECIPES
            SizedBox(
              height: 255,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RecipeCard(
                    recipe: dummyRecipes[0],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: dummyRecipes[0]),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  RecipeCard(
                    recipe: dummyRecipes[1],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: dummyRecipes[1]),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  RecipeCard(
                    recipe: dummyRecipes[2],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipe: dummyRecipes[2]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
