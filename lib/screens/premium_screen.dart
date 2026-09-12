import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isYearlySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'RacikAI Premium',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PREMIUM HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE8D5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 42,
                        color: Color(0xFFE8752E),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Masak lebih pintar\ntanpa batas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Dapatkan pengalaman RacikAI lengkap dengan fitur Premium.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Yang kamu dapatkan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
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

              const Text(
                'Pilih paket',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 14),

              // MONTHLY
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

              // YEARLY
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

              const Text(
                'Free vs Premium',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 14),

              const _ComparisonCard(),

              const SizedBox(height: 24),

              const Center(
                child: Text(
                  'Batalkan kapan saja.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                ),
              ),
            ],
          ),
        ),
      ),

      // FIXED UPGRADE BUTTON
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7),
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: FilledButton(
            onPressed: () {
              final selectedPlan = isYearlySelected
                  ? 'Tahunan - Rp120.000'
                  : 'Bulanan - Rp15.000';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Paket dipilih: $selectedPlan. Pembayaran akan ditambahkan pada tahap berikutnya.',
                  ),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE8752E),
              foregroundColor: Colors.white,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: const Color(0xFFE8752E)),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Color(0xFF777777),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF3E9) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE8752E)
                  : const Color(0xFFEEEEEE),
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
                    color: isSelected
                        ? const Color(0xFFE8752E)
                        : const Color(0xFFCCCCCC),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8752E),
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
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
                              color: const Color(0xFFE8752E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                color: Colors.white,
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),

                  Text(
                    period,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: const Column(
        children: [
          _ComparisonHeader(),

          Divider(height: 28, color: Color(0xFFEEEEEE)),

          _ComparisonRow(feature: 'Cari resep', free: '✓', premium: '✓'),

          _ComparisonRow(
            feature: 'Pertanyaan AI',
            free: '5 / hari',
            premium: 'Unlimited',
          ),

          _ComparisonRow(
            feature: 'Resep favorit',
            free: '10',
            premium: 'Unlimited',
          ),

          _ComparisonRow(feature: 'Meal Planner', free: '—', premium: '✓'),

          _ComparisonRow(
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
    return const Row(
      children: [
        Expanded(
          flex: 2,
          child: Text('Fitur', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: Text(
            'Free',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text(
            'Premium',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFE8752E),
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
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF2F2F2))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
            ),
          ),

          Expanded(
            child: Text(
              free,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF777777)),
            ),
          ),

          Expanded(
            child: Text(
              premium,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8752E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
