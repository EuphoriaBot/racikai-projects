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

  final List<String> ingredientList;

  final String instructions;
  final String? imageUrl;

  const AiRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.ingredientList = const [],
    this.imageUrl,
  });

  factory AiRecipe.fromJson(Map<String, dynamic> json) {
    final rawIngredientList =
        json['ingredient_list'] as List<dynamic>? ?? const <dynamic>[];

    final ingredientList = rawIngredientList
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return AiRecipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: json['ingredients'] as String,
      ingredientList: ingredientList,
      instructions: json['instructions'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }
}
