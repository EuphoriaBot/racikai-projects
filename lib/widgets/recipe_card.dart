import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String category;
  final String duration;
  final String emoji;

  const RecipeCard({
    super.key,
    required this.title,
    required this.category,
    required this.duration,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE8D5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 58)),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border, size: 20),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 9),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xFFE8752E),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
