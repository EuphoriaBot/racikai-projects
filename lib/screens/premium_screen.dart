import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isYearlySelected = true;

  void _activatePremium() {
    final plan = isYearlySelected
        ? SubscriptionPlan.yearly
        : SubscriptionPlan.monthly;

    SubscriptionController.instance.activatePremium(plan);

    final planName = isYearlySelected ? 'Premium Tahunan' : 'Premium Bulanan';

    final messenger = ScaffoldMessenger.of(context);

    context.pop();

    messenger.showSnackBar(
      SnackBar(content: Text('$planName berhasil diaktifkan (mode demo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'RacikAI Premium',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                10,
                isWide ? 24 : 16,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWide)
                        _DesktopPremiumTop(
                          isYearlySelected: isYearlySelected,
                          onMonthlySelected: () {
                            setState(() {
                              isYearlySelected = false;
                            });
                          },
                          onYearlySelected: () {
                            setState(() {
                              isYearlySelected = true;
                            });
                          },
                          onUpgrade: _activatePremium,
                        )
                      else ...[
                        const _PremiumHero(),
                        const SizedBox(height: 30),
                        const _BenefitsSection(),
                        const SizedBox(height: 32),
                        _PlanSection(
                          isYearlySelected: isYearlySelected,
                          onMonthlySelected: () {
                            setState(() {
                              isYearlySelected = false;
                            });
                          },
                          onYearlySelected: () {
                            setState(() {
                              isYearlySelected = true;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 38),

                      Text(
                        'Free vs Premium',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const _ComparisonCard(),

                      const SizedBox(height: 26),

                      if (!isWide) ...[
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _activatePremium,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                            ),
                            child: Text(
                              isYearlySelected
                                  ? 'Pilih Premium Tahunan'
                                  : 'Pilih Premium Bulanan',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                      ],

                      Center(
                        child: Text(
                          'Mode demo • Tidak ada pembayaran nyata.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
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

class _DesktopPremiumTop extends StatelessWidget {
  final bool isYearlySelected;
  final VoidCallback onMonthlySelected;
  final VoidCallback onYearlySelected;
  final VoidCallback onUpgrade;

  const _DesktopPremiumTop({
    required this.isYearlySelected,
    required this.onMonthlySelected,
    required this.onYearlySelected,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 6,
          child: Column(
            children: [
              _PremiumHero(alignLeft: true),
              SizedBox(height: 28),
              _BenefitsSection(compact: true),
            ],
          ),
        ),

        const SizedBox(width: 32),

        Expanded(
          flex: 5,
          child: _DesktopPurchaseCard(
            isYearlySelected: isYearlySelected,
            onMonthlySelected: onMonthlySelected,
            onYearlySelected: onYearlySelected,
            onUpgrade: onUpgrade,
          ),
        ),
      ],
    );
  }
}

class _PremiumHero extends StatelessWidget {
  final bool alignLeft;

  const _PremiumHero({this.alignLeft = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(alignLeft ? 30 : 24),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: alignLeft
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 30,
              color: colors.secondary,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Masak lebih bebas\ndengan RacikAI',
            textAlign: alignLeft ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontSize: alignLeft ? 36 : 29,
              height: 1.12,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
              color: colors.onSecondaryContainer,
            ),
          ),

          const SizedBox(height: 12),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Nikmati AI tanpa batas, simpan lebih banyak resep, '
              'dan susun rencana makan mingguan.',
              textAlign: alignLeft ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: colors.onSecondaryContainer.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitsSection extends StatelessWidget {
  final bool compact;

  const _BenefitsSection({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    const benefits = [
      (
        Icons.auto_awesome_rounded,
        'AI tanpa batas',
        'Tanya RacikAI kapan saja tanpa batas pertanyaan harian.',
      ),
      (
        Icons.favorite_border_rounded,
        'Simpan resep tanpa batas',
        'Bangun koleksi resep favorit sebanyak yang kamu inginkan.',
      ),
      (
        Icons.calendar_month_outlined,
        'Meal Planner',
        'Susun menu Senin sampai Minggu dengan lebih teratur.',
      ),
      (
        Icons.tune_rounded,
        'Pencarian bahan lanjutan',
        'Cari ide resep dengan pilihan bahan yang lebih fleksibel.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yang kamu dapatkan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 14),

        if (compact)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: benefits.map((benefit) {
              return SizedBox(
                width: 260,
                child: _PremiumFeature(
                  icon: benefit.$1,
                  title: benefit.$2,
                  description: benefit.$3,
                ),
              );
            }).toList(),
          )
        else
          ...benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PremiumFeature(
                icon: benefit.$1,
                title: benefit.$2,
                description: benefit.$3,
              ),
            ),
          ),
      ],
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: colors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
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

class _PlanSection extends StatelessWidget {
  final bool isYearlySelected;
  final VoidCallback onMonthlySelected;
  final VoidCallback onYearlySelected;

  const _PlanSection({
    required this.isYearlySelected,
    required this.onMonthlySelected,
    required this.onYearlySelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih paket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Kamu dapat mengganti pilihan sebelum mengaktifkan Premium.',
          style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
        ),

        const SizedBox(height: 14),

        _PlanCard(
          title: 'Bulanan',
          price: 'Rp15.000',
          period: '/ bulan',
          description: 'Fleksibel untuk mencoba Premium',
          isSelected: !isYearlySelected,
          onTap: onMonthlySelected,
        ),

        const SizedBox(height: 12),

        _PlanCard(
          title: 'Tahunan',
          price: 'Rp120.000',
          period: '/ tahun',
          description: 'Setara Rp10.000 per bulan',
          badge: 'HEMAT Rp60.000',
          isSelected: isYearlySelected,
          onTap: onYearlySelected,
        ),
      ],
    );
  }
}

class _DesktopPurchaseCard extends StatelessWidget {
  final bool isYearlySelected;
  final VoidCallback onMonthlySelected;
  final VoidCallback onYearlySelected;
  final VoidCallback onUpgrade;

  const _DesktopPurchaseCard({
    required this.isYearlySelected,
    required this.onMonthlySelected,
    required this.onYearlySelected,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih paket',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Pilih paket Premium yang paling sesuai.',
            style: TextStyle(fontSize: 12.5, color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 18),

          _PlanCard(
            title: 'Bulanan',
            price: 'Rp15.000',
            period: '/ bulan',
            description: 'Fleksibel untuk mencoba Premium',
            isSelected: !isYearlySelected,
            onTap: onMonthlySelected,
          ),

          const SizedBox(height: 12),

          _PlanCard(
            title: 'Tahunan',
            price: 'Rp120.000',
            period: '/ tahun',
            description: 'Setara Rp10.000 per bulan',
            badge: 'HEMAT Rp60.000',
            isSelected: isYearlySelected,
            onTap: onYearlySelected,
          ),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: onUpgrade,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
            ),
            child: Text(
              isYearlySelected
                  ? 'Pilih Premium Tahunan'
                  : 'Pilih Premium Bulanan',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 11),

          Center(
            child: Text(
              'Aktivasi menggunakan mode demo.',
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
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

    return Material(
      color: isSelected
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 23,
                height: 23,
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
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),

                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.secondaryContainer,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: colors.onSecondaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                      ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colors.onSurfaceVariant,
                    ),
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const _ComparisonHeader(),

          Divider(height: 28, color: colors.outlineVariant),

          const _ComparisonRow(feature: 'Cari resep', free: '✓', premium: '✓'),

          const _ComparisonRow(
            feature: 'Pertanyaan AI',
            free: '5 / hari',
            premium: 'Tanpa batas',
          ),

          const _ComparisonRow(
            feature: 'Resep tersimpan',
            free: '10',
            premium: 'Tanpa batas',
          ),

          const _ComparisonRow(
            feature: 'Meal Planner',
            free: '—',
            premium: '✓',
          ),

          const _ComparisonRow(
            feature: 'Pencarian bahan lanjutan',
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
              fontSize: 12,
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
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
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
            ),
          ),

          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
            ),
          ),

          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
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
