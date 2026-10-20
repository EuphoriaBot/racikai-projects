import 'package:flutter/material.dart';

class RecipeHeroHeader extends StatelessWidget {
  final String firstLine;
  final String secondLine;
  final String subtitle;
  final String? imageUrl;
  final Widget? searchBar;

  const RecipeHeroHeader({
    super.key,
    required this.firstLine,
    required this.secondLine,
    required this.subtitle,
    this.searchBar,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 360;
        final isTablet = width >= 600;

        final bannerHeight = isCompact
            ? 244.0
            : isTablet
            ? 294.0
            : 264.0;

        final photoSize = isCompact
            ? 158.0
            : isTablet
            ? 235.0
            : 188.0;

        final headlineSize = isCompact
            ? 29.0
            : isTablet
            ? 40.0
            : 33.0;

        final photoUrl = imageUrl?.trim();
        final hasImage = photoUrl != null && photoUrl.isNotEmpty;

        Widget imageFallback() {
          return const ColoredBox(
            color: Color(0xFF829778),
            child: Center(
              child: Icon(
                Icons.soup_kitchen_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
          );
        }

        return SizedBox(
          height: bannerHeight + (searchBar == null ? 0 : 28),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: searchBar == null ? 0 : 28,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF294334), Color(0xFF536F51)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (hasImage)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.17,
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          ),
                        ),

                      Positioned(
                        top: -30,
                        left: -40,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Icon(
                            Icons.spa_rounded,
                            size: 145,
                            color: Colors.white.withValues(alpha: 0.075),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: -24,
                        left: 90,
                        child: Transform.rotate(
                          angle: 0.45,
                          child: Icon(
                            Icons.eco_rounded,
                            size: 115,
                            color: const Color(0xFFDCE8C9)
                                .withValues(alpha: 0.12),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 12,
                        right: -28,
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Icon(
                            Icons.spa_outlined,
                            size: 105,
                            color: const Color(0xFFE4D5AA)
                                .withValues(alpha: 0.13),
                          ),
                        ),
                      ),

                      Positioned(
                        top: isCompact ? 44 : 38,
                        right: isCompact ? -38 : -30,
                        width: photoSize,
                        height: photoSize,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.33),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.20),
                                blurRadius: 25,
                                offset: const Offset(-5, 8),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: hasImage
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return imageFallback();
                                    },
                                  )
                                : imageFallback(),
                          ),
                        ),
                      ),

                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0, 0.43, 1],
                                colors: [
                                  const Color(0xFF243B2D)
                                      .withValues(alpha: 0.76),
                                  const Color(0xFF294334)
                                      .withValues(alpha: 0.48),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 20,
                        right: isCompact
                            ? 96
                            : isTablet
                            ? photoSize * 0.65
                            : 125,
                        top: isCompact
                            ? 55
                            : isTablet
                            ? 78
                            : 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: headlineSize,
                                height: 1.12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.7,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              secondLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: headlineSize,
                                height: 1.12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.7,
                                color: const Color(0xFFF0DEAF),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: isCompact ? 15 : 16,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: Material(
                  elevation: 1,
                  color: Colors.transparent,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: searchBar,
                ),
              ),

              if (searchBar != null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: Material(
                    elevation: 1,
                    color: Colors.transparent,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: searchBar!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
