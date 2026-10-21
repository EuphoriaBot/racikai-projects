import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'dart:math';

import '../../../../services/recipe_catalog_service.dart';
import '../../../../widgets/recipe_hero_header.dart';
import '../../data/models/chat_message.dart';
import '../../data/datasources/ai_service.dart';
import '../../../../core/router/recipe_detail_route_args.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AiContent();
  }
}

class _AiContent extends StatefulWidget {
  const _AiContent();

  @override
  State<_AiContent> createState() => _AiContentState();
}

class _AiContentState extends State<_AiContent> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AiService aiService = AiService();

  final RecipeCatalogService _catalogService = RecipeCatalogService();

  String? _aiHeroImageUrl;

  @override
  void initState() {
    super.initState();
    _loadRandomHeroImage();
  }

  Future<void> _loadRandomHeroImage() async {
    try {
      const pageSize = 24;
      final random = Random();

      final firstResult = await _catalogService.getRecipes(
        category: 'Semua',
        page: 1,
        limit: pageSize,
      );

      if (!mounted || firstResult.total <= 0) return;

      final totalPages = (firstResult.total + pageSize - 1) ~/ pageSize;

      for (int attempt = 0; attempt < 4; attempt++) {
        final randomPage = 1 + random.nextInt(totalPages);

        final result = randomPage == 1
            ? firstResult
            : await _catalogService.getRecipes(
                category: 'Semua',
                page: randomPage,
                limit: pageSize,
              );

        if (!mounted) return;

        final candidates = result.recipes.where((recipe) {
          final image = recipe.imageUrl;

          return image != null &&
              image.trim().isNotEmpty &&
              !recipe.title.toLowerCase().contains('pasta');
        }).toList();

        if (candidates.isEmpty) continue;

        final selected = candidates[random.nextInt(candidates.length)];

        setState(() {
          _aiHeroImageUrl = selected.imageUrl;
        });

        return;
      }
    } catch (_) {}
  }

  bool isTyping = false;

  final List<ChatMessage> messages = [
    const ChatMessage(
      role: ChatRole.assistant,
      text:
          'Halo! 👋 Aku RacikAI. Beritahu aku bahan yang kamu punya '
          'atau resep yang ingin kamu cari.',
    ),
  ];

  final List<String> suggestions = [
    'Saya punya ayam dan kecap',
    'Resep sederhana tanpa oven',
    'Masak apa dari telur?',
  ];

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    aiService.dispose();
    _catalogService.dispose();
    super.dispose();
  }

  Future<void> sendMessage({String? suggestion}) async {
    final question = suggestion ?? messageController.text.trim();

    if (question.isEmpty || isTyping) {
      return;
    }

    setState(() {
      messages.add(ChatMessage(role: ChatRole.user, text: question));

      messageController.clear();
      isTyping = true;
    });

    scrollToBottom();

    try {
      final response = await aiService.ask(question);

      if (!mounted) {
        return;
      }

      setState(() {
        messages.add(response);
      });
    } on AiServiceException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        messages.add(
          ChatMessage(role: ChatRole.assistant, text: error.message),
        );

        messageController.text = question;
      });
    } finally {
      if (mounted) {
        setState(() {
          isTyping = false;
        });

        scrollToBottom();
      }
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final horizontalPadding = isWide ? 24.0 : 16.0;

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          if (messages.length == 1) ...[
                            RecipeHeroHeader(
                              firstLine: 'Masak bareng',
                              secondLine: 'RacikAI',
                              subtitle: 'Asisten AI siap bantu\nkamu memasak',
                              imageUrl: _aiHeroImageUrl,
                              searchBar: Container(
                                width: double.infinity,
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: colors.primaryContainer,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 18,
                                        color: colors.primary,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        'Asisten resep AI',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ),

                                    Icon(
                                      Icons.restaurant_menu_rounded,
                                      size: 20,
                                      color: colors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                18,
                                horizontalPadding,
                                24,
                              ),
                              child: _AiWelcome(
                                suggestions: suggestions,
                                onSuggestionTap: (suggestion) {
                                  sendMessage(suggestion: suggestion);
                                },
                              ),
                            ),
                          ] else
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                22,
                                horizontalPadding,
                                24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...messages.map((message) {
                                    return _ChatMessageBubble(message: message);
                                  }),

                                  if (isTyping) ...[
                                    const SizedBox(height: 4),
                                    const _TypingBubble(),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                _AiInputBar(
                  controller: messageController,
                  isTyping: isTyping,
                  onChanged: () {
                    setState(() {});
                  },
                  onSend: sendMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AiWelcome extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const _AiWelcome({required this.suggestions, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Mau masak apa?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: colors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Center(
          child: Text(
            'Pilih pertanyaan atau ceritakan bahan yang kamu punya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Coba tanyakan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.primary,
          ),
        ),

        const SizedBox(height: 10),

        for (final suggestion in suggestions) ...[
          _SuggestionTile(
            text: suggestion,
            onTap: () {
              onSuggestionTap(suggestion);
            },
          ),

          if (suggestion != suggestions.last) const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.primaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: colors.secondary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onChanged;
  final Future<void> Function({String? suggestion}) onSend;

  const _AiInputBar({
    required this.controller,
    required this.isTyping,
    required this.onChanged,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final canSend = controller.text.trim().isNotEmpty && !isTyping;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        onChanged: (_) {
                          onChanged();
                        },
                        decoration: InputDecoration(
                          hintText: 'Tanyakan sesuatu...',
                          hintStyle: TextStyle(color: colors.onSurfaceVariant),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Material(
                        color: canSend
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: canSend
                              ? () {
                                  onSend();
                                }
                              : null,
                          child: SizedBox(
                            width: 43,
                            height: 43,
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: 20,
                              color: canSend
                                  ? colors.onPrimary
                                  : colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (isUser)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(5),
                  ),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RacikAI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _cleanAiText(message.text),
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.65,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          if (message.recipes.isNotEmpty) ...[
            const SizedBox(height: 14),

            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.sizeOf(context).width < 360 ? 0 : 41,
              ),
              child: _AiRecipeSources(recipes: message.recipes),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiRecipeSources extends StatelessWidget {
  final List<AiRecipe> recipes;

  const _AiRecipeSources({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rekomendasi resep',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                '${recipes.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...recipes.map((recipe) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AiRecipeCard(recipe: recipe),
            );
          }),
        ],
      ),
    );
  }
}

class _AiRecipeCard extends StatelessWidget {
  final AiRecipe recipe;

  const _AiRecipeCard({required this.recipe});

  void _openDetail(BuildContext context) {
    context.push(
      '/catalog-recipe/${recipe.id}',
      extra: RecipeDetailRouteArgs(recipe: recipe, isAiRecommendation: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openDetail(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _RecipeThumbnail(imageUrl: recipe.imageUrl),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
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
                              size: 12,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Pick',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        recipe.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu_rounded,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),

                          const SizedBox(width: 5),

                          Expanded(
                            child: Text(
                              'Bahan & langkah lengkap',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Lihat resep',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 3),

                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: colors.primary,
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
      ),
    );
  }
}

class _RecipeThumbnail extends StatelessWidget {
  final String? imageUrl;

  const _RecipeThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          imageUrl!,
          width: 92,
          height: 92,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return const _RecipeThumbnailPlaceholder();
          },
        ),
      );
    }

    return const _RecipeThumbnailPlaceholder();
  }
}

class _RecipeThumbnailPlaceholder extends StatelessWidget {
  const _RecipeThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.secondaryContainer],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.86),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.restaurant_rounded, color: colors.primary, size: 24),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: colors.primary,
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          'RacikAI sedang meracik...',
          style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

String _cleanAiText(String text) {
  var result = text;

  result = result.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');

  result = result.replaceAll('**', '');

  result = result.replaceAll(RegExp(r'^\*\s+', multiLine: true), '• ');

  result = result
      .replaceAll('â€“', '–')
      .replaceAll('â€”', '—')
      .replaceAll('Â°F', '°F');

  return result.trim();
}
