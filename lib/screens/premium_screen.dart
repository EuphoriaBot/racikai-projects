import 'package:flutter/material.dart';

import '../controllers/subscription_controller.dart';

import 'package:go_router/go_router.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isYearlySelected = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'RacikAI Premium',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 42,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Masak lebih pintar\ntanpa batas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Dapatkan pengalaman RacikAI lengkap dengan fitur Premium.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Yang kamu dapatkan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              const _PremiumFeature(
                icon: Icons.auto_awesome,
                title: 'AI tanpa batas',
                description:
                    'Tanya RacikAI kapan saja tanpa batas pertanyaan harian.',
              ),

              const _PremiumFeature(
                icon: Icons.favorite_rounded,
                title: 'Simpan resep tanpa batas',
                description:
                    'Simpan semua resep favoritmu tanpa batas maksimal.',
              ),

              const _PremiumFeature(
                icon: Icons.tune_rounded,
                title: 'Pencarian bahan lanjutan',
                description: 'Dapatkan rekomendasi resep yang lebih fleksibel dari bahanmu.',
              ),

              const _PremiumFeature(
                icon: Icons.calendar_month_rounded,
                title: 'Meal Planner',
                description:
                    'Rencanakan menu makanan untuk beberapa hari ke depan.',
              ),

              const _PremiumFeature(
                icon: Icons.block_rounded,
                title: 'Tanpa iklan',
                description:
                    'Nikmati RacikAI dengan pengalaman yang lebih bersih.',
              ),

              const SizedBox(height: 32),

              Text(
                'Pilih paket',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              _PlanCard(
                title: 'Bulanan',
                price: 'Rp15.000',
                period: '/ bulan',
                description: 'Fleksibel, berhenti kapan saja',
                isSelected: !isYearlySelected,
                onTap: () {
                  setState(() {
                    isYearlySelected = false;
                  });
                },
              ),

              const SizedBox(height: 12),

              _PlanCard(
                title: 'Tahunan',
                price: 'Rp120.000',
                period: '/ tahun',
                description: 'Hemat Rp60.000 per tahun',
                badge: 'PALING HEMAT',
                isSelected: isYearlySelected,
                onTap: () {
                  setState(() {
                    isYearlySelected = true;
                  });
                },
              ),

              const SizedBox(height: 34),

              Text(
                'Free vs Premium',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              const _ComparisonCard(),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'Batalkan kapan saja.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: FilledButton(
            onPressed: () {
              final plan = isYearlySelected
                  ? SubscriptionPlan.yearly
                  : SubscriptionPlan.monthly;

              SubscriptionController.instance.activatePremium(plan);

              final planName = isYearlySelected
                  ? 'Premium Tahunan'
                  : 'Premium Bulanan';

              final messenger = ScaffoldMessenger.of(context);

              context.pop();

              messenger.showSnackBar(
                SnackBar(
                  content: Text('$planName berhasil diaktifkan (mode demo).'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              isYearlySelected
                  ? 'Pilih Premium Tahunan'
                  : 'Pilih Premium Bulanan',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: colors.primary),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String description;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final cardBackground = isSelected
        ? colors.primaryContainer
        : colors.surface;

    final mainTextColor = isSelected
        ? colors.onPrimaryContainer
        : colors.onSurface;

    final secondaryTextColor = isSelected
        ? colors.onPrimaryContainer.withValues(alpha: 0.75)
        : colors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colors.primary : colors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: mainTextColor,
                            ),
                          ),
                        ),

                        if (badge != null) ...[
                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: colors.onPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: mainTextColor,
                    ),
                  ),

                  Text(
                    period,
                    style: TextStyle(fontSize: 11, color: secondaryTextColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          const _ComparisonHeader(),

          Divider(height: 28, color: colors.outlineVariant),

          const _ComparisonRow(feature: 'Cari resep', free: '✓', premium: '✓'),

          const _ComparisonRow(
            feature: 'Pertanyaan AI',
            free: '5 / hari',
            premium: 'Unlimited',
          ),

          const _ComparisonRow(
            feature: 'Resep favorit',
            free: '10',
            premium: 'Unlimited',
          ),

          const _ComparisonRow(
            feature: 'Meal Planner',
            free: '—',
            premium: '✓',
          ),

          const _ComparisonRow(
            feature: 'Tanpa iklan',
            free: '—',
            premium: '✓',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Fitur',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Free',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),

        Expanded(
          child: Text(
            'Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String feature;
  final String free;
  final String premium;
  final bool isLast;

  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.premium,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),

          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ),

          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
