import 'package:flutter/material.dart';

import '../widgets/recipe_card.dart';
import '../data/dummy_recipes.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onAiTap;

  const HomeScreen({
    super.key,
    required this.onSearchTap,
    required this.onAiTap,
  });

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'RacikAI',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Selamat datang 👋',
              style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
            ),

            const SizedBox(height: 4),

            const Text(
              'Mau masak apa hari ini?',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 22),

            InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF888888)),
                    SizedBox(width: 12),
                    Text(
                      'Cari resep...',
                      style: TextStyle(color: Color(0xFF999999), fontSize: 15),
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
                color: const Color(0xFFFFE8D5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8752E),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Punya bahan di rumah?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242424),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Beritahu RacikAI bahan yang kamu punya dan temukan resep yang cocok untuk dibuat.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF666666),
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton.icon(
                    onPressed: onAiTap,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Tanya RacikAI'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE8752E),
                      foregroundColor: Colors.white,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kategori',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: onSearchTap,
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: const Color(0xFFE8752E),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rekomendasi untukmu',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: onSearchTap,
                  child: const Text('Lihat Semua'),
                ),
              ],
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
