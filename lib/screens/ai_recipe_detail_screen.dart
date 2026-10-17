import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/ai/data/models/chat_message.dart';
import '../features/favorite/data/models/saved_recipe.dart';
import '../features/favorite/presentation/cubit/favorite_cubit.dart';
import '../features/favorite/presentation/cubit/favorite_state.dart';

class AiRecipeDetailScreen extends StatelessWidget {
  final AiRecipe recipe;
  final bool isAiRecommendation;

  const AiRecipeDetailScreen({
    super.key,
    required this.recipe,
    this.isAiRecommendation = true,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final ingredients = recipe.ingredientList.isNotEmpty
        ? recipe.ingredientList
        : (recipe.ingredients.trim().isEmpty
              ? <String>[]
              : <String>[recipe.ingredients.trim()]);

    final steps = _parseInstructions(recipe.instructions);

    return BlocListener<FavoriteCubit, FavoriteState>(
      listenWhen: (previous, current) {
        return previous.actionId != current.actionId;
      },
      listener: (context, state) {
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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 42),
                child: Column(
                  children: [
                    if (isWide)
                      _DesktopTopSection(
                        recipe: recipe,
                        ingredientsCount: ingredients.length,
                        stepsCount: steps.length,
                        isAiRecommendation: isAiRecommendation,
                      )
                    else ...[
                      _MobileHero(recipe: recipe),
                      _MobileSummary(
                        recipe: recipe,
                        ingredientsCount: ingredients.length,
                        stepsCount: steps.length,
                        isAiRecommendation: isAiRecommendation,
                      ),
                    ],

                    const SizedBox(height: 26),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 16,
                          ),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _IngredientsSection(
                                        ingredients: ingredients,
                                      ),
                                    ),
                                    const SizedBox(width: 42),
                                    Expanded(
                                      flex: 6,
                                      child: _StepsSection(steps: steps),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _IngredientsSection(
                                      ingredients: ingredients,
                                    ),
                                    const SizedBox(height: 38),
                                    _StepsSection(steps: steps),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1100),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 24 : 16,
                          ),
                          child: const _DatasetNote(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<String> _parseInstructions(String raw) {
    final cleaned = raw
        .replaceAll('â€“', '–')
        .replaceAll('â€”', '—')
        .replaceAll('â€™', '’')
        .replaceAll('Â°F', '°F');

    final matches = RegExp(r'[^.!?]+(?:[.!?]+|$)').allMatches(cleaned);

    return matches
        .map((match) => match.group(0)?.trim() ?? '')
        .where((step) => step.isNotEmpty)
        .toList();
  }
}

class _DesktopTopSection extends StatelessWidget {
  final AiRecipe recipe;
  final int ingredientsCount;
  final int stepsCount;
  final bool isAiRecommendation;

  const _DesktopTopSection({
    required this.recipe,
    required this.ingredientsCount,
    required this.stepsCount,
    required this.isAiRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: AspectRatio(
                  aspectRatio: 1.18,
                  child: _RecipeHero(recipe: recipe, borderRadius: 28),
                ),
              ),
              const SizedBox(width: 42),
              Expanded(
                flex: 5,
                child: _RecipeSummary(
                  recipe: recipe,
                  ingredientsCount: ingredientsCount,
                  stepsCount: stepsCount,
                  isAiRecommendation: isAiRecommendation,
                  large: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileHero extends StatelessWidget {
  final AiRecipe recipe;

  const _MobileHero({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 265,
      child: _RecipeHero(recipe: recipe, borderRadius: 0, bottomRadius: 26),
    );
  }
}

class _MobileSummary extends StatelessWidget {
  final AiRecipe recipe;
  final int ingredientsCount;
  final int stepsCount;
  final bool isAiRecommendation;

  const _MobileSummary({
    required this.recipe,
    required this.ingredientsCount,
    required this.stepsCount,
    required this.isAiRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
          child: _RecipeSummary(
            recipe: recipe,
            ingredientsCount: ingredientsCount,
            stepsCount: stepsCount,
            isAiRecommendation: isAiRecommendation,
          ),
        ),
      ),
    );
  }
}

class _RecipeSummary extends StatelessWidget {
  final AiRecipe recipe;
  final int ingredientsCount;
  final int stepsCount;
  final bool isAiRecommendation;
  final bool large;

  const _RecipeSummary({
    required this.recipe,
    required this.ingredientsCount,
    required this.stepsCount,
    required this.isAiRecommendation,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAiRecommendation) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rekomendasi RacikAI',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Text(
          recipe.title,
          style: TextStyle(
            fontSize: large ? 37 : 23,
            height: 1.18,
            letterSpacing: large ? -0.9 : -0.45,
            fontWeight: FontWeight.w900,
            color: colors.onSurface,
          ),
        ),

        if (isAiRecommendation) ...[
          const SizedBox(height: 13),
          Text(
            'Direkomendasikan berdasarkan bahan dan '
            'kebutuhan yang kamu tanyakan.',
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],

        const SizedBox(height: 22),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _RecipeMetadata(
              icon: Icons.restaurant_menu_outlined,
              text: '$ingredientsCount bahan',
            ),
            _RecipeMetadata(
              icon: Icons.format_list_numbered_rounded,
              text: '$stepsCount langkah',
            ),
          ],
        ),

        if (large) ...[
          const SizedBox(height: 28),
          Text(
            'Siapkan bahan terlebih dahulu, lalu ikuti '
            'langkah memasak secara berurutan.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _RecipeMetadata extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RecipeMetadata({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),

          const SizedBox(width: 7),

          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  final AiRecipe recipe;
  final double borderRadius;
  final double? bottomRadius;

  const _RecipeHero({
    required this.recipe,
    required this.borderRadius,
    this.bottomRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasImage =
        recipe.imageUrl != null && recipe.imageUrl!.trim().isNotEmpty;

    final radius = BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(bottomRadius ?? borderRadius),
      bottomRight: Radius.circular(bottomRadius ?? borderRadius),
    );

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              recipe.imageUrl!,
              fit: BoxFit.cover,
              semanticLabel: 'Gambar resep ${recipe.title}',
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  color: colors.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                );
              },
              errorBuilder: (_, _, _) {
                return _imagePlaceholder(context);
              },
            )
          else
            _imagePlaceholder(context),

          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 14,
            left: 14,
            child: _HeroCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Kembali',
              onPressed: () {
                Navigator.of(context).maybePop();
              },
            ),
          ),

          Positioned(
            top: 14,
            right: 14,
            child: BlocBuilder<FavoriteCubit, FavoriteState>(
              buildWhen: (previous, current) {
                return previous.favoriteIds != current.favoriteIds;
              },
              builder: (context, state) {
                final isFavorite = state.isFavorite(recipe.id);

                return _HeroCircleButton(
                  icon: isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  tooltip: isFavorite ? 'Hapus dari tersimpan' : 'Simpan resep',
                  iconColor: isFavorite ? colors.secondary : colors.onSurface,
                  onPressed: () {
                    context.read<FavoriteCubit>().toggleBackendFavorite(
                      SavedRecipe.fromAiRecipe(recipe),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_outlined,
        size: 58,
        color: colors.primary.withValues(alpha: 0.72),
      ),
    );
  }
}

class _HeroCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? iconColor;

  const _HeroCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 44, height: 44),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.94),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: iconColor ?? colors.onSurface),
      ),
    );
  }
}

class _IngredientsSection extends StatelessWidget {
  final List<String> ingredients;

  const _IngredientsSection({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentSectionHeader(
          title: 'Bahan',
          subtitle: ingredients.isEmpty
              ? 'Informasi bahan belum tersedia.'
              : 'Centang bahan yang sudah kamu siapkan.',
          trailing: ingredients.isEmpty ? null : '${ingredients.length} bahan',
        ),

        const SizedBox(height: 15),

        if (ingredients.isEmpty)
          _EmptyContent(
            icon: Icons.restaurant_outlined,
            text: 'Daftar bahan belum tersedia.',
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                for (int i = 0; i < ingredients.length; i++)
                  _IngredientTile(
                    ingredient: ingredients[i],
                    showDivider: i != ingredients.length - 1,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  final List<String> steps;

  const _StepsSection({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContentSectionHeader(
          title: 'Cara membuat',
          subtitle: steps.isEmpty
              ? 'Instruksi memasak belum tersedia.'
              : 'Ikuti langkah berikut secara berurutan.',
          trailing: steps.isEmpty ? null : '${steps.length} langkah',
        ),

        const SizedBox(height: 18),

        if (steps.isEmpty)
          const _EmptyContent(
            icon: Icons.format_list_numbered_rounded,
            text: 'Instruksi memasak belum tersedia.',
          )
        else
          ...List.generate(steps.length, (index) {
            return _CookingStep(
              number: index + 1,
              text: steps[index],
              isLast: index == steps.length - 1,
            );
          }),
      ],
    );
  }
}

class _ContentSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;

  const _ContentSectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: colors.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            height: 1.4,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IngredientTile extends StatefulWidget {
  final String ingredient;
  final bool showDivider;

  const _IngredientTile({required this.ingredient, required this.showDivider});

  @override
  State<_IngredientTile> createState() => _IngredientTileState();
}

class _IngredientTileState extends State<_IngredientTile> {
  bool _isPrepared = false;

  void _togglePrepared() {
    setState(() {
      _isPrepared = !_isPrepared;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _togglePrepared,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(top: 2),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPrepared ? colors.primary : Colors.transparent,
                      border: Border.all(
                        color: _isPrepared ? colors.primary : colors.outline,
                        width: 1.6,
                      ),
                    ),
                    child: _isPrepared
                        ? Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: colors.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 170),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.48,
                        color: _isPrepared
                            ? colors.onSurfaceVariant
                            : colors.onSurface,
                        decoration: _isPrepared
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: colors.onSurfaceVariant,
                        decorationThickness: 1.4,
                      ),
                      child: Text(widget.ingredient),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Divider(height: 1, indent: 49, color: colors.outlineVariant),
      ],
    );
  }
}

class _CookingStep extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _CookingStep({
    required this.number,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ),

            if (!isLast)
              Container(
                width: 1,
                height: 34,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: colors.outlineVariant,
              ),
          ],
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 18),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: colors.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyContent extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyContent({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: colors.onSurfaceVariant),
          const SizedBox(height: 9),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DatasetNote extends StatelessWidget {
  const _DatasetNote();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            'Resep berasal dari koleksi dataset RacikAI. '
            'Sesuaikan jumlah bahan dan kebutuhan makananmu '
            'jika diperlukan.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
