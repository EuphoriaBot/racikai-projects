import '../../../ai/data/models/chat_message.dart';

class CatalogRecipe {
  final String id;
  final String title;
  final String ingredients;
  final List<String> ingredientList;
  final String instructions;
  final String? imageName;
  final String? imageUrl;
  final int ingredientCount;

  const CatalogRecipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.ingredientCount,
    this.ingredientList = const [],
    this.imageName,
    this.imageUrl,
  });

  factory CatalogRecipe.fromJson(Map<String, dynamic> json) {
    final rawIngredientList =
        json['ingredient_list'] as List<dynamic>? ?? const <dynamic>[];

    final ingredientList = rawIngredientList
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();

    return CatalogRecipe(
      id: json['id'] as String,
      title: json['title'] as String,
      ingredients: json['ingredients'] as String,
      ingredientList: ingredientList,
      instructions: json['instructions'] as String,
      ingredientCount: json['ingredient_count'] as int,
      imageName: json['image_name'] as String?,
      imageUrl: json['image_url'] as String?,
    );
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

class CatalogPage {
  final List<CatalogRecipe> recipes;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const CatalogPage({
    required this.recipes,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory CatalogPage.fromJson(Map<String, dynamic> json) {
    return CatalogPage(
      recipes: (json['recipes'] as List<dynamic>)
          .map((item) => CatalogRecipe.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      hasMore: json['has_more'] as bool,
    );
  }
}
