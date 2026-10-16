import 'package:flutter/material.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String query;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const RecipeSearchBar({
    super.key,
    this.controller,
    this.query = '',
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: colors.primary),

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
              color: colors.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}
