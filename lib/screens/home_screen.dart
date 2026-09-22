import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../data/dummy_recipes.dart';
import '../widgets/recipe_card.dart';

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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(18),
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

            const SizedBox(height: 20),

            InkWell(
              onTap: onSearchTap,
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
                    Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
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

            Container(
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

                  const SizedBox(height: 16),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        final isPremium =
                            SubscriptionController.instance.isPremium;

                        if (isPremium) {
                          context.push('/meal-planner');
                        } else {
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
                                      context.push('/premium');
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

                  const SizedBox(height: 16),

                  Text(
                    'Beritahu RacikAI bahan yang kamu punya dan temukan resep yang cocok untuk dibuat.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: colors.onPrimaryContainer.withValues(alpha: 0.78),
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton.icon(
                    onPressed: () {
                      context.push('/ingredients');
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Cari dari Bahan'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.surface,
                      foregroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _SectionHeader(
              title: 'Kategori',
              actionLabel: 'Lihat Semua',
              onTap: onSearchTap,
            ),

            const SizedBox(height: 14),

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

            const SizedBox(height: 28),

            _SectionHeader(
              title: 'Rekomendasi untukmu',
              actionLabel: 'Lihat Semua',
              onTap: onSearchTap,
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 255,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RecipeCard(
                    recipe: dummyRecipes[0],
                    onTap: () {
                      context.push('/recipe/${dummyRecipes[0].id}');
                    },
                  ),
                  const SizedBox(width: 16),
                  RecipeCard(
                    recipe: dummyRecipes[1],
                    onTap: () {
                      context.push('/recipe/${dummyRecipes[1].id}');
                    },
                  ),
                  const SizedBox(width: 16),
                  RecipeCard(
                    recipe: dummyRecipes[2],
                    onTap: () {
                      context.push('/recipe/${dummyRecipes[2].id}');
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
