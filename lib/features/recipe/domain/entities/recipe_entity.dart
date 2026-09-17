import 'package:equatable/equatable.dart';

class RecipeEntity extends Equatable {
  final int id;
  final String title;
  final String category;
  final String duration;
  final String emoji;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.emoji,
    required this.description,
    required this.ingredients,
    required this.instructions,
  });

  @override
  List<Object> get props => [
    id,
    title,
    category,
    duration,
    emoji,
    description,
    ingredients,
    instructions,
  ];
}
