import 'package:flutter/material.dart';

import '../data/dummy_recipes.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';
import '../controllers/favorite_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String searchQuery = '';
  String selectedCategory = 'Semua';

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'Semua',
    'Ayam',
    'Daging',
    'Nasi',
    'Pasta',
    'Sayur',
    'Dessert',
  ];

  List<Recipe> get filteredRecipes {
    return dummyRecipes.where((recipe) {
      final matchesSearch =
          recipe.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          recipe.category.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesCategory =
          selectedCategory == 'Semua' || recipe.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cari Resep',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Temukan resep yang ingin kamu masak.',
                  style: TextStyle(color: Color(0xFF777777), fontSize: 14),
                ),

                const SizedBox(height: 22),

                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari ayam, pasta, nasi...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();

                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 17),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFFE8752E),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];

                final isSelected = selectedCategory == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  showCheckmark: false,
                  selectedColor: const Color(0xFFE8752E),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFFE8752E)
                        : const Color(0xFFEEEEEE),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 22),

          Expanded(
            child: filteredRecipes.isEmpty
                ? const _EmptySearch()
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = MediaQuery.sizeOf(context).width;

                          final horizontalPadding = screenWidth >= 600
                              ? 28.0
                              : 20.0;

                          int columnCount;

                          if (constraints.maxWidth >= 900) {
                            columnCount = 4;
                          } else if (constraints.maxWidth >= 600) {
                            columnCount = 3;
                          } else {
                            columnCount = 2;
                          }

                          return GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              30,
                            ),
                            itemCount: filteredRecipes.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 245,
                                ),
                            itemBuilder: (context, index) {
                              final recipe = filteredRecipes[index];

                              return _SearchRecipeGridCard(recipe: recipe);
                            },
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchRecipeGridCard extends StatelessWidget {
  final Recipe recipe;

  const _SearchRecipeGridCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR / EMOJI
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          recipe.emoji,
                          style: const TextStyle(fontSize: 52),
                        ),
                      ),

                      Positioned(
                        top: 10,
                        right: 10,
                        child: AnimatedBuilder(
                          animation: FavoriteController.instance,
                          builder: (context, _) {
                            final isFavorite = FavoriteController.instance
                                .isFavorite(recipe.id);

                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  final result = FavoriteController.instance
                                      .toggleFavorite(recipe.id);

                                  if (result == FavoriteResult.limitReached) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Batas 10 resep favorit tercapai.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 20,
                                  color: isFavorite
                                      ? colors.primary
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      recipe.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: colors.primary,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            recipe.duration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: colors.outline,
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

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Color(0xFFCCCCCC)),

            SizedBox(height: 16),

            Text(
              'Resep tidak ditemukan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 6),

            Text(
              'Coba gunakan kata kunci atau kategori lain.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ],
        ),
      ),
    );
  }
}
