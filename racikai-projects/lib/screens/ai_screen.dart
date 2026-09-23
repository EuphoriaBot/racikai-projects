import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/usage_controller.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

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
    aiService.dispose();
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

    scrollToBottom();
    try {
      final response = await aiService.ask(question);
      usage.recordAiQuestion();
      if (!mounted) return;
      setState(() => messages.add(response));
    } on AiServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        messages.add(
          ChatMessage(role: ChatRole.assistant, text: error.message),
        );
        messageController.text = question;
      });
    } finally {
      if (mounted) {
        setState(() => isTyping = false);
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

          if (message.recipes.isNotEmpty) ...[
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: _RecipeSources(recipes: message.recipes),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeSources extends StatelessWidget {
  final List<AiRecipe> recipes;
  const _RecipeSources({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sumber resep',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...recipes.map(
          (recipe) => Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: Text(recipe.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                showDragHandle: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.4,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, controller) => ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bahan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(recipe.ingredients),
                      const SizedBox(height: 24),
                      Text(
                        'Cara memasak',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SelectableText(recipe.instructions),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
