import 'package:flutter/material.dart';

import '../models/chat_message.dart';

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
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final ingredients = _parseIngredients(recipe.ingredients);
    final steps = _parseInstructions(recipe.instructions);

    final heroHeight = screenWidth >= 700 ? 360.0 : 300.0;

    return Scaffold(
      backgroundColor: colors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: heroHeight,
            pinned: true,
            stretch: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,

            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.all(9),
              child: _HeroActionButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Kembali',
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: const [StretchMode.zoomBackground],
              background: _RecipeHero(
                imageUrl: recipe.imageUrl,
                recipeTitle: recipe.title,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
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
                            const SizedBox(width: 5),
                            Text(
                              isAiRecommendation
                                  ? 'Rekomendasi RacikAI'
                                  : 'Resep RacikAI',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 30,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        isAiRecommendation
                            ? 'Resep ini direkomendasikan RacikAI berdasarkan '
                                  'bahan dan kebutuhan yang kamu tanyakan.'
                            : 'Resep dari koleksi RacikAI. Lihat bahan dan '
                                  'ikuti langkah memasaknya di bawah.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.restaurant_menu_rounded,
                              value: '${ingredients.length}',
                              label: 'Bahan',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.format_list_numbered_rounded,
                              value: '${steps.length}',
                              label: 'Langkah',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 34),

                      _SectionHeader(
                        icon: Icons.restaurant_rounded,
                        title: 'Bahan',
                        subtitle: 'Siapkan bahan berikut sebelum memasak.',
                      ),

                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: colors.outlineVariant),
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

                      const SizedBox(height: 38),

                      _SectionHeader(
                        icon: Icons.format_list_numbered_rounded,
                        title: 'Langkah Memasak',
                        subtitle: 'Ikuti langkah secara berurutan untuk hasil terbaik.',
                      ),

                      const SizedBox(height: 16),

                      ...List.generate(
                        steps.length,
                        (index) =>
                            _CookingStep(number: index + 1, text: steps[index]),
                      ),

                      const SizedBox(height: 22),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Resep berasal dari dataset RacikAI. '
                                'Sesuaikan jumlah bahan, waktu memasak, '
                                'dan kebutuhan makananmu jika diperlukan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseIngredients(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
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

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeroActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: colors.onSurface),
      ),
    );
  }
}

class _RecipeHero extends StatelessWidget {
  final String? imageUrl;
  final String recipeTitle;

  const _RecipeHero({required this.imageUrl, required this.recipeTitle});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasImage)
          Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            semanticLabel: 'Gambar resep $recipeTitle',
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return _loadingPlaceholder(context, loadingProgress);
            },
            errorBuilder: (_, _, _) {
              return _placeholder(context);
            },
          )
        else
          _placeholder(context),

        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingPlaceholder(
    BuildContext context,
    ImageChunkEvent loadingProgress,
  ) {
    final colors = Theme.of(context).colorScheme;

    final expectedBytes = loadingProgress.expectedTotalBytes;

    final progress = expectedBytes != null
        ? loadingProgress.cumulativeBytesLoaded / expectedBytes
        : null;

    return Container(
      color: colors.surfaceContainerHighest,
      alignment: Alignment.center,
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          color: colors.primary,
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      child: Center(
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.88),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_rounded,
            size: 45,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
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
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final String ingredient;
  final bool showDivider;

  const _IngredientTile({required this.ingredient, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary, width: 1.7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 48, color: colors.outlineVariant),
      ],
    );
  }
}

class _CookingStep extends StatelessWidget {
  final int number;
  final String text;

  const _CookingStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: TextStyle(
                color: colors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
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
      ),
    );
  }
}
