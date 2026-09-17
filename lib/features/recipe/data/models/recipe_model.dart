import '../../domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.category,
    required super.duration,
    required super.emoji,
    required super.description,
    required super.ingredients,
    required super.instructions,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      duration: json['duration'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'duration': duration,
      'emoji': emoji,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
