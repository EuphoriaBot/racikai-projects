import 'package:flutter/material.dart';

import '../controllers/favorite_controller.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: FavoriteController.instance,
        builder: (context, _) {
          final favorites = FavoriteController.instance.favoriteRecipes;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resep Tersimpan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      favorites.isEmpty
                          ? 'Belum ada resep yang disimpan.'
                          : '${favorites.length} resep tersimpan',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Expanded(
                child: favorites.isEmpty
                    ? const _EmptySaved()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        itemCount: favorites.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _SavedRecipeCard(recipe: favorites[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SavedRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _SavedRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
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
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            children: [
              Container(
                width: 115,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8D5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(recipe.emoji, style: const TextStyle(fontSize: 48)),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              FavoriteController.instance.toggleFavorite(
                                recipe.id,
                              );
                            },
                            icon: const Icon(
                              Icons.favorite,
                              size: 21,
                              color: Color(0xFFE8752E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        recipe.category,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
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
                            size: 14,
                            color: Color(0xFFAAAAAA),
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
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 70,
              color: Color(0xFFCCCCCC),
            ),

            SizedBox(height: 18),

            Text(
              'Belum ada resep favorit',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),

            SizedBox(height: 8),

            Text(
              'Tekan ikon hati pada resep yang kamu suka dan resep akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
