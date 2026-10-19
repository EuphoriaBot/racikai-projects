import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FoodPreferencesScreen extends StatefulWidget {
  final String initialPreference;

  const FoodPreferencesScreen({super.key, required this.initialPreference});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  static const options = [
    _FoodOption(
      title: 'Tidak ada',
      description: 'Tanpa preferensi khusus',
      icon: Icons.restaurant_outlined,
    ),
    _FoodOption(
      title: 'Vegetarian',
      description: 'Tanpa daging dan ikan',
      icon: Icons.eco_outlined,
    ),
    _FoodOption(
      title: 'Vegan',
      description: 'Tanpa bahan hewani',
      icon: Icons.spa_outlined,
    ),
    _FoodOption(
      title: 'Halal',
      description: 'Mengutamakan makanan halal',
      icon: Icons.verified_outlined,
    ),
    _FoodOption(
      title: 'Rendah gula',
      description: 'Mengurangi konsumsi gula',
      icon: Icons.water_drop_outlined,
    ),
  ];

  late String selectedPreference;

  @override
  void initState() {
    super.initState();

    selectedPreference =
        options.any((option) => option.title == widget.initialPreference)
        ? widget.initialPreference
        : 'Tidak ada';
  }

  void savePreference() {
    context.pop<String>(selectedPreference);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        titleSpacing: 0,
        title: const Text(
          'Preferensi Makanan',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),

            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),

              children: [
                Text(
                  'Apa gaya makanmu?',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Pilih satu preferensi yang paling '
                  'sesuai dengan kebutuhanmu.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 22),

                for (final option in options) ...[
                  _PreferenceChoiceTile(
                    option: option,
                    selected: selectedPreference == option.title,
                    onTap: () {
                      setState(() {
                        selectedPreference = option.title;
                      });
                    },
                  ),

                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 17,
                      color: colors.onSurfaceVariant,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Preferensi ini belum otomatis '
                        'memfilter resep atau rekomendasi AI.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),

          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 528),

              child: SizedBox(
                width: double.infinity,
                height: 52,

                child: FilledButton.icon(
                  onPressed: savePreference,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Simpan preferensi'),

                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodOption {
  final String title;
  final String description;
  final IconData icon;

  const _FoodOption({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _PreferenceChoiceTile extends StatelessWidget {
  final _FoodOption option;
  final bool selected;
  final VoidCallback onTap;

  const _PreferenceChoiceTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colors.primaryContainer.withValues(alpha: 0.5)
          : colors.surface,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(option.icon, size: 21, color: colors.primary),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      option.description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 23,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
