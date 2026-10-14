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

        const SizedBox(height: 22),

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

        const SizedBox(height: 28),

        _IngredientChoices(
          ingredients: filteredIngredients,
          selectedIngredients: selectedIngredients,
          onToggle: onToggleIngredient,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Apa yang ada di dapurmu?',
          style: TextStyle(
            fontSize: 27,
            height: 1.1,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Pilih bahan yang tersedia. '
          'RacikAI akan membantu mencarikan '
          'resep yang paling cocok.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
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

  const _IngredientChoices({
    required this.ingredients,
    required this.selectedIngredients,
    required this.onToggle,
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
            padding: const EdgeInsets.symmetric(vertical: 34),
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
            children: ingredients.map((ingredient) {
              final isSelected = selectedIngredients.contains(ingredient);

              return FilterChip(
                label: Text(ingredient),
                selected: isSelected,
                onSelected: (_) {
                  onToggle(ingredient);
                },
                showCheckmark: true,
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
