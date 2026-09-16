import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/favorite/favorite_cubit.dart';
import '../cubits/favorite/favorite_state.dart';
import '../models/recipe.dart';

import 'package:go_router/go_router.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: BlocBuilder<FavoriteCubit, FavoriteState>(
        builder: (context, state) {
          final favorites = context.read<FavoriteCubit>().favoriteRecipes;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resep Tersimpan',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      favorites.isEmpty
                          ? 'Belum ada resep yang disimpan.'
                          : '${favorites.length} resep tersimpan',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.push('/recipe/${recipe.id}');
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              // IMAGE / EMOJI AREA
              Container(
                width: 115,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: const BorderRadius.only(
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                          ),

                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              context.read<FavoriteCubit>().toggleFavorite(
                                recipe.id,
                              );
                            },
                            icon: Icon(
                              Icons.favorite,
                              size: 21,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      Text(
                        recipe.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Spacer(),

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

                          const Spacer(),

                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 70,
              color: colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),

            const SizedBox(height: 18),

            Text(
              'Belum ada resep favorit',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Tekan ikon hati pada resep yang kamu suka dan resep akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
