import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return BlocListener<FavoriteCubit, FavoriteState>(
      listenWhen: (previous, current) {
        return previous.actionId != current.actionId;
      },
      listener: (context, state) {
        if (state.action == FavoriteAction.limitReached) {
          _showFavoriteLimitDialog(context);
          return;
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (state.action == FavoriteAction.added) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 900),
              content: Text('Resep disimpan'),
            ),
          );
        }

        if (state.action == FavoriteAction.removed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(milliseconds: 900),
              content: Text('Resep dihapus dari tersimpan'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'Detail Resep',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            _FavoriteButton(recipeId: recipe.id),
            const SizedBox(width: 6),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 850;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 24 : 16,
                  12,
                  isWide ? 24 : 16,
                  40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: isWide
                        ? _DesktopDetail(recipe: recipe)
                        : _MobileDetail(recipe: recipe),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final int recipeId;

  const _FavoriteButton({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<FavoriteCubit, FavoriteState>(
      buildWhen: (previous, current) {
        return previous.favoriteIds != current.favoriteIds;
      },
      builder: (context, state) {
        final isFavorite = state.isFavorite(recipeId);

        return IconButton(
          tooltip: isFavorite ? 'Hapus dari tersimpan' : 'Simpan resep',
          onPressed: () {
            context.read<FavoriteCubit>().toggleFavorite(recipeId);
          },
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? colors.secondary : colors.onSurfaceVariant,
          ),
        );
      },
    );
  }
}

class _MobileDetail extends StatelessWidget {
  final RecipeEntity recipe;

  const _MobileDetail({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeHero(recipe: recipe, compact: true),

        const SizedBox(height: 24),

        _RecipeTitle(recipe: recipe),

        const SizedBox(height: 22),

        _RecipeStats(recipe: recipe),

        const SizedBox(height: 34),

        _IngredientsSection(recipe: recipe),

        const SizedBox(height: 34),

        _InstructionsSection(recipe: recipe),

        const SizedBox(height: 34),
      ],
    );
  }
}

class _DesktopDetail extends StatelessWidget {
  final RecipeEntity recipe;

  const _DesktopDetail({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _RecipeHero(recipe: recipe, compact: false),

              const SizedBox(height: 18),

              _RecipeStats(recipe: recipe),

              const SizedBox(height: 20),
            ],
          ),
        ),

        const SizedBox(width: 36),

        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeTitle(recipe: recipe),

              const SizedBox(height: 34),

              _IngredientsSection(recipe: recipe),

              const SizedBox(height: 38),

              _InstructionsSection(recipe: recipe),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeHero extends StatelessWidget {
  final RecipeEntity recipe;
  final bool compact;

  const _RecipeHero({required this.recipe, required this.compact});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: compact ? 220 : 390,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(compact ? 24 : 28),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                recipe.category,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              recipe.emoji,
              style: TextStyle(fontSize: compact ? 100 : 150),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeTitle extends StatelessWidget {
  final RecipeEntity recipe;

  const _RecipeTitle({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.category,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          recipe.title,
          style: TextStyle(
            fontSize: 30,
            height: 1.15,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 13),

        Text(
          recipe.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RecipeStats extends StatelessWidget {
  final RecipeEntity recipe;

  const _RecipeStats({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatItem(
            icon: Icons.schedule_rounded,
            label: 'Waktu',
            value: recipe.duration,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatItem(
            icon: Icons.restaurant_menu_rounded,
            label: 'Bahan',
            value: '${recipe.ingredients.length} item',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),

          const SizedBox(height: 9),

          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 2),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final RecipeEntity recipe;

  const _IngredientsSection({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bahan-bahan',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
            ),
            Text(
              '${recipe.ingredients.length} item',
              style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
            ),
          ],
        ),

        const SizedBox(height: 17),

        ...recipe.ingredients.map((ingredient) {
          return _IngredientItem(ingredient: ingredient);
        }),
      ],
    );
  }
}

class _IngredientItem extends StatelessWidget {
  final String ingredient;

  const _IngredientItem({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 15, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                ingredient,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsSection extends StatelessWidget {
  final RecipeEntity recipe;

  const _InstructionsSection({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara membuat',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 20),

        ...List.generate(recipe.instructions.length, (index) {
          return _InstructionItem(
            number: index + 1,
            instruction: recipe.instructions[index],
            isLast: index == recipe.instructions.length - 1,
          );
        }),
      ],
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
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimary,
                  ),
                ),
              ),

              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: colors.outlineVariant,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 28),
              child: Text(
                instruction,
                style: TextStyle(
                  fontSize: 14.5,
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

void _showFavoriteLimitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      final colors = Theme.of(dialogContext).colorScheme;

      return AlertDialog(
        icon: Icon(Icons.favorite_rounded, size: 40, color: colors.secondary),
        title: const Text('Batas Resep Tersimpan', textAlign: TextAlign.center),
        content: Text(
          'Akun Free dapat menyimpan maksimal '
          '${FavoriteCubit.freeFavoriteLimit} resep. '
          'Upgrade ke Premium untuk menyimpan '
          'resep tanpa batas.',
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
            child: const Text('Upgrade Premium'),
          ),
        ],
      );
    },
  );
}
