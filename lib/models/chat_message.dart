enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<int> sourceRecipeIds;

  const ChatMessage({
    required this.role,
    required this.text,
    this.sourceRecipeIds = const [],
  });
}
