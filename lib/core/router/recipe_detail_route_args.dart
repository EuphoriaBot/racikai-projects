import '../../models/chat_message.dart';

class RecipeDetailRouteArgs {
  final AiRecipe recipe;
  final bool isAiRecommendation;

  const RecipeDetailRouteArgs({
    required this.recipe,
    required this.isAiRecommendation,
  });
}
