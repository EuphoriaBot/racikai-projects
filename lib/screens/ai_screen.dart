import 'package:flutter/material.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/usage_controller.dart';
import '../data/dummy_recipes.dart';
import '../models/chat_message.dart';
import '../models/recipe.dart';
import 'premium_screen.dart';
import 'recipe_detail_screen.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  bool isTyping = false;

  final List<ChatMessage> messages = [
    const ChatMessage(
      role: ChatRole.assistant,
      text: 'Halo! 👋 Aku RacikAI. Beritahu aku bahan yang kamu punya atau resep yang ingin kamu cari.',
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

    usage.recordAiQuestion();

    scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final response = generateDummyResponse(question);

    setState(() {
      messages.add(response);
      isTyping = false;
    });

    scrollToBottom();
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
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

  ChatMessage generateDummyResponse(String question) {
    final text = question.toLowerCase();

    if (text.contains('ayam') ||
        text.contains('chicken') ||
        text.contains('kecap')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Dari bahan yang kamu sebutkan, kamu bisa mencoba Garlic Soy Chicken 🍗.\n\n'
            'Resep ini menggunakan ayam, bawang putih, kecap, minyak, dan sedikit garam. '
            'Proses memasaknya juga cukup sederhana dan cocok untuk menu sehari-hari.',
        sourceRecipeIds: [1, 6],
      );
    }

    if (text.contains('nasi') || text.contains('rice')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Kalau kamu punya nasi, salah satu pilihan paling sederhana adalah Nasi Goreng Spesial 🍚.\n\n'
            'Kamu bisa mengombinasikannya dengan telur, bawang putih, dan kecap.',
        sourceRecipeIds: [2, 8],
      );
    }

    if (text.contains('pasta')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Kamu bisa mencoba Creamy Chicken Pasta 🍝. '
            'Resep ini cocok kalau kamu punya pasta, ayam, susu, bawang putih, dan keju.',
        sourceRecipeIds: [3],
      );
    }

    if (text.contains('daging') || text.contains('beef')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Untuk bahan daging sapi, Beef Teriyaki bisa menjadi pilihan yang praktis 🥩. '
            'Rasanya manis dan gurih serta proses memasaknya cukup sederhana.',
        sourceRecipeIds: [4],
      );
    }

    if (text.contains('sayur') ||
        text.contains('wortel') ||
        text.contains('brokoli')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Kamu bisa membuat Vegetable Stir Fry 🥬. '
            'Cukup gunakan beberapa sayuran yang tersedia lalu tumis bersama bawang putih dan sedikit saus.',
        sourceRecipeIds: [5],
      );
    }

    if (text.contains('telur')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Telur bisa digunakan untuk banyak menu sederhana. '
            'Dari resep yang tersedia, kamu bisa mencoba Nasi Goreng Spesial atau Beef Fried Rice.',
        sourceRecipeIds: [2, 8],
      );
    }

    if (text.contains('dessert') ||
        text.contains('cokelat') ||
        text.contains('pancake')) {
      return const ChatMessage(
        role: ChatRole.assistant,
        text:
            'Kalau ingin sesuatu yang manis, coba Chocolate Pancake 🥞. '
            'Bahannya sederhana seperti tepung, telur, susu, cokelat bubuk, dan gula.',
        sourceRecipeIds: [7],
      );
    }

    return const ChatMessage(
      role: ChatRole.assistant,
      text:
          'Aku belum menemukan kecocokan yang sangat spesifik dari pertanyaan itu. '
          'Coba sebutkan bahan utama yang kamu punya, misalnya ayam, nasi, telur, pasta, daging, atau sayuran.',
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
                            '$usage / ${UsageController.freeAiLimit} pertanyaan hari ini',
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

          if (message.sourceRecipeIds.isNotEmpty) ...[
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

class _RecipeSources extends StatelessWidget {
  final List<int> recipeIds;

  const _RecipeSources({required this.recipeIds});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final List<Recipe> recipes = dummyRecipes.where((recipe) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(recipe.emoji, style: const TextStyle(fontSize: 28)),

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
