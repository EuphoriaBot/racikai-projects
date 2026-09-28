enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String text;
  final List<int> sourceRecipeIds;
  final List<AiRecipe> recipes;

  const ChatMessage({
    required this.role,
    required this.text,
    this.sourceRecipeIds = const [],
    this.recipes = const [],
  });
}

class AiRecipe {
  final String id;
  final String title;
  final String ingredients;
  final String instructions;
  final String? imageUrl;

  const AiRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
  });

  factory AiRecipe.fromJson(Map<String, dynamic> json) {
    return AiRecipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: json['ingredients'] as String,
      instructions: json['instructions'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}
