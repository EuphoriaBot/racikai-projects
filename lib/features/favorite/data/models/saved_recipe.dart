import '../../../ai/data/models/chat_message.dart';
import '../../../recipe/data/models/catalog_recipe.dart';

class SavedRecipe {
  final String id;
  final String title;
  final String ingredients;
  final List<String> ingredientList;
  final String instructions;
  final String? imageName;
  final String? imageUrl;
  final int ingredientCount;

  const SavedRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.ingredientCount,
    this.ingredientList = const [],
    this.imageName,
    this.imageUrl,
  });

  factory SavedRecipe.fromCatalogRecipe(CatalogRecipe recipe) {
    return SavedRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      ingredientList: recipe.ingredientList,
      instructions: recipe.instructions,
      imageName: recipe.imageName,
      imageUrl: recipe.imageUrl,
      ingredientCount: recipe.ingredientCount,
    );
  }

  factory SavedRecipe.fromAiRecipe(AiRecipe recipe) {
    return SavedRecipe(
      id: recipe.id,
      title: recipe.title,
      ingredients: recipe.ingredients,
      ingredientList: recipe.ingredientList,
      instructions: recipe.instructions,
      imageUrl: recipe.imageUrl,
      ingredientCount: recipe.ingredientList.length,
    );
  }

  factory SavedRecipe.fromJson(Map<String, dynamic> json) {
    final rawIngredientList = json['ingredient_list'];

    final ingredientList = rawIngredientList is List
        ? rawIngredientList
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList()
        : <String>[];

    final savedIngredientCount = (json['ingredient_count'] as num?)?.toInt();

    return SavedRecipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: json['ingredients'] as String,
      ingredientList: ingredientList,
      instructions: json['instructions'] as String,
      imageName: json['image_name'] as String?,
      imageUrl: json['image_url'] as String?,
      ingredientCount: savedIngredientCount ?? ingredientList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'ingredient_list': ingredientList,
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
      ingredientList: ingredientList,
      instructions: instructions,
      imageUrl: imageUrl,
    );
  }
}
