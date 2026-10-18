import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  void clearSearch() {
    searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  void openResults() {
    if (selectedIngredients.isEmpty) {
      return;
    }

    context.push('/ingredients/results', extra: selectedIngredients.toList());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Dari bahan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                14,
                isWide ? 24 : 16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: isWide
                      ? _DesktopLayout(
                          searchController: searchController,
                          searchQuery: searchQuery,
                          selectedIngredients: selectedIngredients,
                          filteredIngredients: filteredIngredients,
                          onSearchChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          onClearSearch: clearSearch,
                          onToggleIngredient: toggleIngredient,
                          onClearSelected: () {
                            setState(() {
                              selectedIngredients.clear();
                            });
                          },
                          onSearchRecipes: openResults,
                        )
                      : _MobileLayout(
                          searchController: searchController,
                          searchQuery: searchQuery,
                          selectedIngredients: selectedIngredients,
                          filteredIngredients: filteredIngredients,
                          onSearchChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          onClearSearch: clearSearch,
                          onToggleIngredient: toggleIngredient,
                          onClearSelected: () {
                            setState(() {
                              selectedIngredients.clear();
                            });
                          },
                          onSearchRecipes: openResults,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Set<String> selectedIngredients;
  final List<String> filteredIngredients;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onToggleIngredient;
  final VoidCallback onClearSelected;
  final VoidCallback onSearchRecipes;

  const _MobileLayout({
    required this.searchController,
    required this.searchQuery,
    required this.selectedIngredients,
    required this.filteredIngredients,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleIngredient,
    required this.onClearSelected,
    required this.onSearchRecipes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Intro(),

        const SizedBox(height: 16),

        _IngredientSearchField(
          controller: searchController,
          query: searchQuery,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),

        if (selectedIngredients.isNotEmpty) ...[
          const SizedBox(height: 26),

          _SelectedIngredients(
            selectedIngredients: selectedIngredients,
            onToggle: onToggleIngredient,
            onClear: onClearSelected,
          ),
        ],

        const SizedBox(height: 22),

        _IngredientChoices(
          ingredients: filteredIngredients,
          selectedIngredients: selectedIngredients,
          onToggle: onToggleIngredient,
          onClearSearch: onClearSearch,
        ),

        const SizedBox(height: 30),

        _SearchRecipeButton(
          count: selectedIngredients.length,
          onPressed: onSearchRecipes,
        ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Set<String> selectedIngredients;
  final List<String> filteredIngredients;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onToggleIngredient;
  final VoidCallback onClearSelected;
  final VoidCallback onSearchRecipes;

  const _DesktopLayout({
    required this.searchController,
    required this.searchQuery,
    required this.selectedIngredients,
    required this.filteredIngredients,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onToggleIngredient,
    required this.onClearSelected,
    required this.onSearchRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Intro(),

                const SizedBox(height: 22),

                _IngredientSearchField(
                  controller: searchController,
                  query: searchQuery,
                  onChanged: onSearchChanged,
                  onClear: onClearSearch,
                ),

                if (selectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 24),

                  _SelectedIngredients(
                    selectedIngredients: selectedIngredients,
                    onToggle: onToggleIngredient,
                    onClear: onClearSelected,
                  ),
                ],

                const SizedBox(height: 26),

                _SearchRecipeButton(
                  count: selectedIngredients.length,
                  onPressed: onSearchRecipes,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 22),

        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _IngredientChoices(
              ingredients: filteredIngredients,
              selectedIngredients: selectedIngredients,
              onToggle: onToggleIngredient,
              onClearSearch: onClearSearch,
            ),
          ),
        ),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apa yang ada di dapurmu?',
            style: TextStyle(
              fontSize: 23,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: colors.onPrimaryContainer,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Pilih bahan yang tersedia, lalu temukan '
            'resep yang paling cocok untukmu.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: colors.onPrimaryContainer.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _IngredientSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari bahan...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
      ),
    );
  }
}

class _SelectedIngredients extends StatelessWidget {
  final Set<String> selectedIngredients;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  const _SelectedIngredients({
    required this.selectedIngredients,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Bahan dipilih',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
            ),

            TextButton(onPressed: onClear, child: const Text('Hapus semua')),
          ],
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedIngredients.map((ingredient) {
            return InputChip(
              label: Text(ingredient),
              onDeleted: () {
                onToggle(ingredient);
              },
              deleteIcon: const Icon(Icons.close_rounded, size: 16),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _IngredientChoices extends StatelessWidget {
  final List<String> ingredients;
  final Set<String> selectedIngredients;
  final ValueChanged<String> onToggle;
  final VoidCallback onClearSearch;

  const _IngredientChoices({
    required this.ingredients,
    required this.selectedIngredients,
    required this.onToggle,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih bahan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Ketuk bahan untuk menambahkan '
          'atau menghapusnya dari pilihan.',
          style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 16),

        if (ingredients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon pencarian
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off_rounded,
                      size: 30,
                      color: colors.primary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Judul
                  Text(
                    'Bahan tidak ditemukan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Deskripsi
                  Text(
                    'Coba gunakan nama bahan yang berbeda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tombol menghapus pencarian
                  OutlinedButton.icon(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Hapus pencarian'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 9,
            runSpacing: 10,
            children: ingredients.map((ingredient) {
              final isSelected = selectedIngredients.contains(ingredient);

              return FilterChip(
                label: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onPrimaryContainer,
                  ),
                ),

                selected: isSelected,

                onSelected: (_) {
                  onToggle(ingredient);
                },

                showCheckmark: true,
                checkmarkColor: colors.onPrimary,

                backgroundColor: colors.primaryContainer.withValues(
                  alpha: 0.55,
                ),

                selectedColor: colors.primary,

                side: BorderSide(
                  color: isSelected ? colors.primary : colors.outlineVariant,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _SearchRecipeButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _SearchRecipeButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: count == 0 ? null : onPressed,
        icon: const Icon(Icons.search_rounded),
        label: Text(
          count == 0
              ? 'Pilih bahan terlebih dahulu'
              : 'Cari resep dari $count bahan',
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
    );
  }
}
