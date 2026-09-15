import 'package:flutter/material.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/usage_controller.dart';
import 'premium_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionController.instance;
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: subscription,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 28),

                // USER PROFILE
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: colors.primaryContainer,
                        child: Icon(
                          subscription.isPremium
                              ? Icons.workspace_premium_rounded
                              : Icons.person_rounded,
                          size: 46,
                          color: colors.primary,
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'Guest User',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subscription.isPremium
                            ? 'RacikAI Premium Member ✨'
                            : 'Cook smarter with RacikAI ✨',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // PLAN
                _PlanOverviewCard(subscription: subscription),

                const SizedBox(height: 30),

                // PREFERENCES
                Text(
                  'Preferensi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
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
                  trailingText: ThemeController.instance.modeLabel,
                  onTap: () {
                    _showThemePicker(context);
                  },
                ),

                const SizedBox(height: 26),

                // ABOUT
                Text(
                  'Tentang',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
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
                          'RacikAI membantu pengguna menemukan resep '
                          'berdasarkan bahan yang dimiliki dan mendapatkan '
                          'rekomendasi resep dengan bantuan AI.',
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

                Center(
                  child: Text(
                    'RacikAI v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
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

void _showThemePicker(BuildContext context) {
  final themeController = ThemeController.instance;

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          final colors = Theme.of(context).colorScheme;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Tampilan',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Sesuaikan tema RacikAI dengan kenyamananmu.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Terang'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Gelap'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.settings_suggest_outlined),
                          label: Text('Sistem'),
                        ),
                      ],
                      selected: {themeController.themeMode},
                      onSelectionChanged: (selection) {
                        themeController.setThemeMode(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _PlanOverviewCard extends StatelessWidget {
  final SubscriptionController subscription;

  const _PlanOverviewCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    final isPremium = subscription.isPremium;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(22),
        border: isPremium
            ? Border.all(color: colors.primary, width: 1.5)
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
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: colors.onPrimaryContainer,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isPremium
                          ? 'Paket ${subscription.planPeriod}'
                          : 'Paket kamu saat ini',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onPrimaryContainer.withValues(
                          alpha: 0.75,
                        ),
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
                                  Text(
                                    'Pertanyaan AI hari ini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  Text(
                                    '$usage / ${UsageController.freeAiLimit}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
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
                                  backgroundColor: colors.surface.withValues(
                                    alpha: 0.65,
                                  ),
                                  color: colors.primary,
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
                color: colors.primary,
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
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
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
                color: colors.surface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 18, color: colors.primary),
                  const SizedBox(width: 7),
                  Text(
                    'Premium aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
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
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colors.onPrimaryContainer,
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
    final colors = Theme.of(context).colorScheme;

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
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: colors.primary),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),

                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
