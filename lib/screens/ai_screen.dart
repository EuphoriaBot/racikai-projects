import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/usage_controller.dart';
import '../core/di/service_locator.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/recipe/presentation/cubit/recipe_cubit.dart';
import '../features/recipe/presentation/cubit/recipe_state.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

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

      // Pertanyaan baru dihitung setelah backend berhasil merespons.
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

        // Supaya pertanyaan mudah dikirim ulang kalau backend bermasalah.
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
          // ==========================================
          // HEADER AI
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
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
                          final isPremium =
                              SubscriptionController.instance.isPremium;

                          if (isPremium) {
                            return Text(
                              'Premium • AI tanpa batas ✨',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.primary,
                              ),
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
          ),

          // ==========================================
          // CHAT
          // ==========================================
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              children: [
                ...messages.map((message) {
                  return _ChatMessageBubble(message: message);
                }),

                if (messages.length == 1) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Coba tanyakan',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions.map((suggestion) {
                      return ActionChip(
                        label: Text(
                          suggestion,
                          style: TextStyle(color: colors.onSurface),
                        ),
                        avatar: Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: colors.primary,
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

          // ==========================================
          // INPUT
          // ==========================================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    onChanged: (_) {
                      setState(() {});
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
                    color: messageController.text.trim().isNotEmpty && !isTyping
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: messageController.text.trim().isEmpty || isTyping
                        ? null
                        : () {
                            sendMessage();
                          },
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color:
                          messageController.text.trim().isNotEmpty && !isTyping
                          ? colors.onPrimary
                          : colors.onSurfaceVariant,
                    ),
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

// ==================================================
// CHAT MESSAGE
// ==================================================

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: isUser ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Backend baru mengembalikan List<AiRecipe>.
          if (message.recipes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: _AiRecipeSources(recipes: message.recipes),
            ),
          ]
          // Fallback untuk struktur lama / dummy lokal.
          else if (message.sourceRecipeIds.isNotEmpty) ...[
            const SizedBox(height: 10),
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

// ==================================================
// RESEP DARI BACKEND AI
// ==================================================

class _AiRecipeSources extends StatelessWidget {
  final List<AiRecipe> recipes;

  const _AiRecipeSources({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 15, color: colors.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              'Resep yang ditemukan',
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
                  _showAiRecipeDetail(context, recipe);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Lihat bahan dan langkah',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onPrimaryContainer.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
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
    );
  }
}

// ==================================================
// DETAIL SEDERHANA RESEP DARI BACKEND
// ==================================================

void _showAiRecipeDetail(BuildContext context, AiRecipe recipe) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final colors = Theme.of(sheetContext).colorScheme;

      return FractionallySizedBox(
        heightFactor: 0.82,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rekomendasi RacikAI',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),

                _AiRecipeSection(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Bahan',
                  content: recipe.ingredients,
                ),

                const SizedBox(height: 28),

                _AiRecipeSection(
                  icon: Icons.format_list_numbered_rounded,
                  title: 'Langkah Memasak',
                  content: recipe.instructions,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AiRecipeSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _AiRecipeSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: colors.primary),
            ),
            const SizedBox(width: 11),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================
// RESEP LOKAL LAMA
// ==================================================

class _RecipeSources extends StatelessWidget {
  final List<int> recipeIds;

  const _RecipeSources({required this.recipeIds});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        if (state is RecipeInitial || state is RecipeLoading) {
          return const SizedBox.shrink();
        }

        if (state is RecipeError) {
          return const SizedBox.shrink();
        }

        if (state is! RecipeLoaded) {
          return const SizedBox.shrink();
        }

        final List<RecipeEntity> recipes = state.recipes.where((recipe) {
          return recipeIds.contains(recipe.id);
        }).toList();

        if (recipes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
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
                                    color: colors.onPrimaryContainer.withValues(
                                      alpha: 0.75,
                                    ),
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
        );
      },
    );
  }
}

// ==================================================
// TYPING INDICATOR
// ==================================================

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
