import 'package:flutter/material.dart';

import '../controllers/favorite_controller.dart';
import '../models/recipe.dart';
import 'premium_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: backgroundColor,
            foregroundColor: colors.onSurface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.90),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: colors.onSurface),
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                    animation: FavoriteController.instance,
                    builder: (context, _) {
                      final isFavorite = FavoriteController.instance.isFavorite(
                        recipe.id,
                      );

                      return IconButton(
                        onPressed: () {
                          final result = FavoriteController.instance
                              .toggleFavorite(recipe.id);

                          if (result == FavoriteResult.limitReached) {
                            _showFavoriteLimitDialog(context);

                            return;
                          }

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 900),
                              content: Text(
                                result == FavoriteResult.added
                                    ? 'Resep disimpan ke favorit'
                                    : 'Resep dihapus dari favorit',
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: colors.primaryContainer,
                alignment: Alignment.center,
                child: Text(
                  recipe.emoji,
                  style: const TextStyle(fontSize: 110),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      recipe.category,
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    recipe.title,
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    recipe.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.schedule_rounded,
                          label: 'Waktu',
                          value: recipe.duration,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _InfoCard(
                          icon: Icons.restaurant_menu_rounded,
                          label: 'Bahan',
                          value: '${recipe.ingredients.length} bahan',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bahan-bahan',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),

                      Text(
                        '${recipe.ingredients.length} item',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...recipe.ingredients.map((ingredient) {
                    return _IngredientItem(ingredient: ingredient);
                  }),

                  const SizedBox(height: 32),

                  Text(
                    'Cara Membuat',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...List.generate(recipe.instructions.length, (index) {
                    return _InstructionItem(
                      number: index + 1,
                      instruction: recipe.instructions[index],
                      isLast: index == recipe.instructions.length - 1,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Mode memasak akan dibuat pada tahap berikutnya.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Mulai Memasak'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showFavoriteLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: Icon(Icons.favorite_rounded, size: 42, color: colors.primary),
        title: const Text(
          'Batas Favorit Tercapai',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'Akun Free dapat menyimpan maksimal 10 resep. '
          'Upgrade ke Premium untuk menyimpan resep tanpa batas.',
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
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: const Text('Upgrade Premium'),
          ),
        ],
      );
    },
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final String ingredient;

  const _IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 16, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              ingredient,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final int number;
  final String instruction;
  final bool isLast;

  const _InstructionItem({
    required this.number,
    required this.instruction,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // CONNECTING LINE
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: colors.primary.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8, bottom: isLast ? 0 : 26),
              child: Text(
                instruction,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
