import '../../../recipe/data/models/catalog_recipe.dart';
import '../../../ai/data/models/chat_message.dart';

class SavedRecipe {
  final String id;
  final String title;
  final String ingredients;
  final String instructions;
  final String? imageName;
  final String? imageUrl;
  final int ingredientCount;

  const SavedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.imageName,
    this.imageUrl,
    required this.ingredientCount,
  });

  factory SavedRecipe.fromCatalogRecipe(CatalogRecipe recipe) {
    return SavedRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageName: recipe.imageName,
      imageUrl: recipe.imageUrl,
      ingredientCount: recipe.ingredientCount,
    );
  }

  factory SavedRecipe.fromAiRecipe(AiRecipe recipe) {
    final ingredientCount = recipe.ingredients
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .length;

    return SavedRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageUrl: recipe.imageUrl,
      ingredientCount: ingredientCount,
    );
  }

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    return SavedRecipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: json['ingredients'] as String,
      instructions: json['instructions'] as String,
      imageName: json['image_name'] as String?,
      imageUrl: json['image_url'] as String?,
      ingredientCount: (json['ingredient_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'image_name': imageName,
      'image_url': imageUrl,
      'ingredient_count': ingredientCount,
    };
  }

  AiRecipe toAiRecipe() {
    return AiRecipe(
      id: id,
      title: title,
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: imageUrl,
    );
  }
}
