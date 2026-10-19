import 'package:flutter/material.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String query;
  final bool readOnly;
  final bool heroStyle;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const RecipeSearchBar({
    super.key,
    this.controller,
    this.query = '',
    this.readOnly = false,
    this.heroStyle = false,
    this.onTap,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = heroStyle && !isDark
        ? const Color(0xFFFFFCF6)
        : colors.surface;

    final borderColor = isDark
        ? colors.outlineVariant
        : const Color(0xFFE2E6DC);

    return Container(
      height: heroStyle ? 50 : 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(heroStyle ? 16 : 14),
        border: heroStyle ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 21, color: colors.primary),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              showCursor: !readOnly,
              enableInteractiveSelection: !readOnly,
              textInputAction: TextInputAction.search,
              onTap: onTap,
              onChanged: onChanged,
              style: TextStyle(fontSize: 14, color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari resep atau bahan...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
                isDense: true,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(width: 8),

          if (!readOnly && query.isNotEmpty)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(20),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            )
          else
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: heroStyle ? colors.primary : colors.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
