import 'package:flutter/material.dart';

import 'ingredient_result_screen.dart';

class IngredientFinderScreen extends StatefulWidget {
  const IngredientFinderScreen({super.key});

  @override
  State<IngredientFinderScreen> createState() => _IngredientFinderScreenState();
}

class _IngredientFinderScreenState extends State<IngredientFinderScreen> {
  final TextEditingController searchController = TextEditingController();

  final Set<String> selectedIngredients = {};

  String searchQuery = '';

  final List<String> availableIngredients = [
    'Ayam',
    'Daging sapi',
    'Telur',
    'Nasi',
    'Pasta',
    'Bawang putih',
    'Bawang merah',
    'Bawang bombai',
    'Kecap',
    'Saus teriyaki',
    'Saus tiram',
    'Cabai',
    'Wortel',
    'Brokoli',
    'Kol',
    'Kentang',
    'Santan',
    'Susu',
    'Keju',
    'Tepung',
    'Gula',
    'Minyak',
    'Garam',
  ];

  List<String> get filteredIngredients {
    if (searchQuery.isEmpty) {
      return availableIngredients;
    }

    return availableIngredients.where((ingredient) {
      return ingredient.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  void toggleIngredient(String ingredient) {
    setState(() {
      if (selectedIngredients.contains(ingredient)) {
        selectedIngredients.remove(ingredient);
      } else {
        selectedIngredients.add(ingredient);
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Bahan Saya',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      'Apa yang ada di dapurmu?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Pilih bahan yang kamu punya. '
                      'RacikAI akan mencari resep '
                      'yang paling cocok.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SEARCH FIELD
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari bahan...',

                        prefixIcon: Icon(
                          Icons.search,
                          color: colors.onSurfaceVariant,
                        ),

                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();

                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: colors.onSurfaceVariant,
                                ),
                              )
                            : null,

                        filled: true,
                        fillColor: colors.surface,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colors.outlineVariant),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: colors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // SELECTED INGREDIENTS
                    if (selectedIngredients.isNotEmpty) ...[
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bahan dipilih',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                            ),
                          ),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedIngredients.clear();
                              });
                            },
                            child: const Text('Hapus Semua'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedIngredients.map((ingredient) {
                          return InputChip(
                            label: Text(ingredient),
                            selected: true,
                            onDeleted: () {
                              toggleIngredient(ingredient);
                            },
                            deleteIcon: Icon(
                              Icons.close,
                              size: 17,
                              color: colors.onPrimaryContainer,
                            ),
                            selectedColor: colors.primaryContainer,
                            side: BorderSide.none,
                            labelStyle: TextStyle(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // AVAILABLE INGREDIENTS
                    Text(
                      'Pilih bahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (filteredIngredients.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Bahan tidak ditemukan.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 9,
                        runSpacing: 10,
                        children: filteredIngredients.map((ingredient) {
                          final isSelected = selectedIngredients.contains(
                            ingredient,
                          );

                          return FilterChip(
                            label: Text(ingredient),

                            selected: isSelected,

                            onSelected: (_) {
                              toggleIngredient(ingredient);
                            },

                            showCheckmark: true,

                            selectedColor: colors.primary,

                            backgroundColor: colors.surface,

                            checkmarkColor: colors.onPrimary,

                            side: BorderSide(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outlineVariant,
                            ),

                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colors.onPrimary
                                  : colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // BOTTOM BUTTON
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: FilledButton(
                onPressed: selectedIngredients.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IngredientResultScreen(
                              selectedIngredients: selectedIngredients.toList(),
                            ),
                          ),
                        );
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,

                  foregroundColor: colors.onPrimary,

                  disabledBackgroundColor: colors.surfaceContainerHighest,

                  disabledForegroundColor: colors.onSurfaceVariant,

                  minimumSize: const Size(double.infinity, 56),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  selectedIngredients.isEmpty
                      ? 'Pilih bahan terlebih dahulu'
                      : 'Cari Resep (${selectedIngredients.length} bahan)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
