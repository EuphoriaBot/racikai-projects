import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/favorite/favorite_cubit.dart';
import '../cubits/favorite/favorite_state.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';

class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final VoidCallback? onTap;

  const RecipeCard({super.key, required this.recipe, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 190,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // IMAGE / EMOJI
              // ==========================================
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        recipe.emoji,
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),

                    // ====================================
                    // FAVORITE BUTTON
                    // ====================================
                    Positioned(
                      top: 10,
                      right: 10,
                      child: BlocBuilder<FavoriteCubit, FavoriteState>(
                        buildWhen: (previous, current) {
                          return previous.favoriteIds != current.favoriteIds;
                        },
                        builder: (context, state) {
                          final isFavorite = state.isFavorite(recipe.id);

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
                                context.read<FavoriteCubit>().toggleFavorite(
                                  recipe.id,
                                );
                              },
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
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

              // ==========================================
              // RECIPE INFORMATION
              // ==========================================
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      recipe.category,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: colors.primary),

                        const SizedBox(width: 5),

                        Text(
                          recipe.duration,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.onSurface,
                          ),
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
