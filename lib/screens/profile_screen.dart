import 'package:flutter/material.dart';

import 'premium_screen.dart';
import '../controllers/subscription_controller.dart';
import 'premium_screen.dart';
import '../controllers/usage_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionController.instance;

    return AnimatedBuilder(
      animation: subscription,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 28),

                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFFFE8D5),
                        child: Icon(
                          subscription.isPremium
                              ? Icons.workspace_premium_rounded
                              : Icons.person_rounded,
                          size: 46,
                          color: const Color(0xFFE8752E),
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Guest User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF222222),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subscription.isPremium
                            ? 'RacikAI Premium Member ✨'
                            : 'Cook smarter with RacikAI ✨',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _PlanOverviewCard(subscription: subscription),

                const SizedBox(height: 30),

                const Text(
                  'Preferensi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 12),

                _ProfileMenuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  onTap: () {},
                ),

                _ProfileMenuItem(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  trailingText: 'Indonesia',
                  onTap: () {},
                ),

                _ProfileMenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Tampilan',
                  onTap: () {},
                ),

                const SizedBox(height: 26),

                const Text(
                  'Tentang',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF222222),
                  ),
                ),

                const SizedBox(height: 12),

                _ProfileMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang RacikAI',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'RacikAI',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text(
                          'RacikAI membantu pengguna menemukan resep berdasarkan bahan yang dimiliki dan mendapatkan rekomendasi resep dengan bantuan AI.',
                        ),
                      ],
                    );
                  },
                ),

                _ProfileMenuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Kebijakan Privasi',
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                const Center(
                  child: Text(
                    'RacikAI v1.0.0',
                    style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanOverviewCard extends StatelessWidget {
  final SubscriptionController subscription;

  const _PlanOverviewCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final isPremium = subscription.isPremium;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8D5),
        borderRadius: BorderRadius.circular(22),
        border: isPremium
            ? Border.all(color: const Color(0xFFE8752E), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.planName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isPremium
                          ? 'Paket ${subscription.planPeriod}'
                          : 'Paket kamu saat ini',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                      ),
                    ),
                    if (!isPremium) ...[
                      const SizedBox(height: 18),

                      AnimatedBuilder(
                        animation: UsageController.instance,
                        builder: (context, _) {
                          final usage = UsageController.instance.aiUsage;

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Pertanyaan AI hari ini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  Text(
                                    '$usage / ${UsageController.freeAiLimit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE8752E),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: usage / UsageController.freeAiLimit,
                                  minHeight: 7,
                                  backgroundColor: Colors.white,
                                  color: const Color(0xFFE8752E),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.auto_awesome,
                color: const Color(0xFFE8752E),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _PlanFeatureRow(
            icon: Icons.auto_awesome,
            text: isPremium
                ? 'Pertanyaan AI tanpa batas'
                : '5 pertanyaan AI per hari',
          ),

          const SizedBox(height: 10),

          _PlanFeatureRow(
            icon: Icons.favorite_outline,
            text: isPremium
                ? 'Simpan resep tanpa batas'
                : 'Maksimal 10 resep favorit',
          ),

          if (!isPremium) ...[
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Upgrade ke Premium'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE8752E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: Color(0xFFE8752E)),
                  SizedBox(width: 7),
                  Text(
                    'Premium aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8752E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanFeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlanFeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFE8752E)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: const Color(0xFFE8752E)),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),

                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFAAAAAA),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
