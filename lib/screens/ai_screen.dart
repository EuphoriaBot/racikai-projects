import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/usage_controller.dart';
import '../core/di/service_locator.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';
import '../features/favorite/ai/data/models/chat_message.dart';
import '../services/ai_service.dart';
import '../core/router/recipe_detail_route_args.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeCubit>()..loadRecipes(),
      child: const _AiContent(),
    );
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
    super.dispose();
  }

  Future<void> sendMessage({String? suggestion}) async {
    final question = suggestion ?? messageController.text.trim();

    if (question.isEmpty || isTyping) {
      return;
    }

    final usage = UsageController.instance;

    if (!usage.canAskAI) {
      showAiLimitDialog();
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

      usage.recordAiQuestion();

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

  void showAiLimitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          icon: Icon(Icons.auto_awesome, size: 42, color: colors.primary),
          title: const Text('Batas AI Tercapai', textAlign: TextAlign.center),
          content: const Text(
            'Kamu sudah menggunakan 5 pertanyaan AI gratis hari ini. '
            'Upgrade ke Premium untuk menggunakan RacikAI tanpa batas.',
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

    return SafeArea(
      child: Column(
        children: [
          _AiHeader(colors: colors),

          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              children: [
                ...messages.map((message) {
                  return _ChatMessageBubble(message: message);
                }),

                if (messages.length == 1) ...[
                  const SizedBox(height: 10),

                  Text(
                    'Coba tanyakan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((suggestion) {
                      return ActionChip(
                        avatar: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: colors.primary,
                        ),
                        label: Text(
                          suggestion,
                          style: TextStyle(color: colors.onSurface),
                        ),
                        backgroundColor: colors.surfaceContainerHighest,
                        side: BorderSide(color: colors.outlineVariant),
                        onPressed: () {
                          sendMessage(suggestion: suggestion);
                        },
                      );
                    }).toList(),
                  ),
                ],

                if (isTyping) ...[
                  const SizedBox(height: 4),
                  const _TypingBubble(),
                ],
              ],
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
      ),
    );
  }
}

class _AiHeader extends StatelessWidget {
  final ColorScheme colors;

  const _AiHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.auto_awesome, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RacikAI Assistant',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

                AnimatedBuilder(
                  animation: UsageController.instance,
                  builder: (context, _) {
                    final isPremium = SubscriptionController.instance.isPremium;

                    if (isPremium) {
                      return Text(
                        'Premium • AI tanpa batas ✨',
                        style: TextStyle(fontSize: 12, color: colors.primary),
                      );
                    }

                    final usage = UsageController.instance.aiUsage;

                    return Text(
                      '$usage / '
                      '${UsageController.freeAiLimit} '
                      'pertanyaan hari ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
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
                  hintText: 'Tanya RacikAI...',
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: canSend
                    ? colors.primary
                    : colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: canSend
                    ? () {
                        onSend();
                      }
                    : null,
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: canSend ? colors.onPrimary : colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
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
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 17,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(width: 8),
              ],

              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser
                          ? colors.primary
                          : colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18),
                      ),
                      border: isUser
                          ? null
                          : Border.all(color: colors.outlineVariant),
                    ),
                    child: Text(
                      isUser ? message.text : _cleanAiText(message.text),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: isUser ? colors.onPrimary : colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (message.recipes.isNotEmpty) ...[
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: _AiRecipeSources(recipes: message.recipes),
            ),
          ] else if (message.sourceRecipeIds.isNotEmpty) ...[
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: _RecipeSources(recipeIds: message.sourceRecipeIds),
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                'Rekomendasi resep',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(width: 7),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${recipes.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
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

                const SizedBox(width: 14),

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
                        children: [
                          Text(
                            'Lihat resep',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
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

                const SizedBox(width: 6),

                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
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

class _RecipeSources extends StatelessWidget {
  final List<int> recipeIds;

  const _RecipeSources({required this.recipeIds});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        if (state is RecipeInitial ||
            state is RecipeLoading ||
            state is RecipeError ||
            state is! RecipeLoaded) {
          return const SizedBox.shrink();
        }

        final List<RecipeEntity> recipes = state.recipes.where((recipe) {
          return recipeIds.contains(recipe.id);
        }).toList();

        if (recipes.isEmpty) {
          return const SizedBox.shrink();
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 15,
                    color: colors.onSurfaceVariant,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    'Sumber resep',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ...recipes.map((recipe) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        context.push('/recipe/${recipe.id}');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Text(
                              recipe.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    recipe.duration,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onPrimaryContainer
                                          .withValues(alpha: 0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: colors.onPrimaryContainer.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.auto_awesome, size: 17, color: colors.primary),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 9),

              Text(
                'RacikAI sedang meracik...',
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
            ],
          ),
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
