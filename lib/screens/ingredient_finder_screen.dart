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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Bahan Saya',
          style: TextStyle(fontWeight: FontWeight.w700),
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
                    const Text(
                      'Apa yang ada di dapurmu?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Pilih bahan yang kamu punya. RacikAI akan mencari resep yang paling cocok.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(height: 24),

                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari bahan...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  searchController.clear();

                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.close),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFEEEEEE),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8752E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    if (selectedIngredients.isNotEmpty) ...[
                      const SizedBox(height: 28),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bahan dipilih',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
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
                            deleteIcon: const Icon(Icons.close, size: 17),
                            selectedColor: const Color(0xFFFFE8D5),
                            side: BorderSide.none,
                            labelStyle: const TextStyle(
                              color: Color(0xFFE8752E),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 30),

                    const Text(
                      'Pilih bahan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (filteredIngredients.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'Bahan tidak ditemukan.',
                            style: TextStyle(color: Color(0xFF888888)),
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
                            selectedColor: const Color(0xFFE8752E),
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFE8752E)
                                  : const Color(0xFFEEEEEE),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF555555),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF7),
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
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
                  backgroundColor: const Color(0xFFE8752E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
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
