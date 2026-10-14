import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/usage_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Guest User';
  String email = 'guest@racikai.app';
  String preference = 'Tidak ada';

  Future<void> _openEditProfile() async {
    final result = await context.push<Map<String, String>>(
      '/profile/edit',
      extra: {'name': name, 'email': email, 'preference': preference},
    );

    if (result == null) {
      return;
    }

    setState(() {
      name = result['name'] ?? name;
      email = result['email'] ?? email;
      preference = result['preference'] ?? preference;
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAboutRacikAI() {
    showAboutDialog(
      context: context,
      applicationName: 'RacikAI',
      applicationVersion: '1.0.0',
      children: const [
        Text(
          'RacikAI membantu pengguna menemukan resep '
          'berdasarkan bahan yang tersedia dan mendapatkan '
          'rekomendasi resep dengan bantuan AI.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionController.instance;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return AnimatedBuilder(
      animation: subscription,
      builder: (context, _) {
        return ColoredBox(
          color: backgroundColor,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 800;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isWide ? 24 : 16,
                    16,
                    isWide ? 24 : 16,
                    24,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _ProfilePageHeader(),

                          const SizedBox(height: 18),

                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: _AccountCard(
                                    name: name,
                                    email: email,
                                    isPremium: subscription.isPremium,
                                    onEdit: _openEditProfile,
                                  ),
                                ),

                                const SizedBox(width: 18),

                                Expanded(
                                  flex: 6,
                                  child: _PlanOverviewCard(
                                    subscription: subscription,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _AccountCard(
                              name: name,
                              email: email,
                              isPremium: subscription.isPremium,
                              onEdit: _openEditProfile,
                            ),

                            const SizedBox(height: 12),

                            _PlanOverviewCard(subscription: subscription),
                          ],

                          const SizedBox(height: 24),

                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _ProfileSection(
                                    title: 'Personalisasi',
                                    child: _SettingsGroup(
                                      children: [
                                        _SettingsItem(
                                          icon: Icons.restaurant_menu_outlined,
                                          title: 'Preferensi makanan',
                                          trailingText: preference,
                                          onTap: _openEditProfile,
                                        ),
                                        _SettingsItem(
                                          icon: Icons.language_rounded,
                                          title: 'Bahasa',
                                          trailingText: 'Indonesia',
                                          onTap: () {
                                            _showInfoMessage(
                                              'Saat ini RacikAI '
                                              'menggunakan Bahasa Indonesia.',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Expanded(
                                  child: _ProfileSection(
                                    title: 'Informasi',
                                    child: _SettingsGroup(
                                      children: [
                                        _SettingsItem(
                                          icon: Icons.info_outline_rounded,
                                          title: 'Tentang RacikAI',
                                          onTap: _showAboutRacikAI,
                                        ),
                                        _SettingsItem(
                                          icon: Icons.lock_outline_rounded,
                                          title: 'Kebijakan Privasi',
                                          onTap: () {
                                            _showInfoMessage(
                                              'Halaman kebijakan privasi '
                                              'belum tersedia.',
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _ProfileSection(
                              title: 'Personalisasi',
                              child: _SettingsGroup(
                                children: [
                                  _SettingsItem(
                                    icon: Icons.restaurant_menu_outlined,
                                    title: 'Preferensi makanan',
                                    trailingText: preference,
                                    onTap: _openEditProfile,
                                  ),
                                  _SettingsItem(
                                    icon: Icons.language_rounded,
                                    title: 'Bahasa',
                                    trailingText: 'Indonesia',
                                    onTap: () {
                                      _showInfoMessage(
                                        'Saat ini RacikAI '
                                        'menggunakan Bahasa Indonesia.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _ProfileSection(
                              title: 'Informasi',
                              child: _SettingsGroup(
                                children: [
                                  _SettingsItem(
                                    icon: Icons.info_outline_rounded,
                                    title: 'Tentang RacikAI',
                                    onTap: _showAboutRacikAI,
                                  ),
                                  _SettingsItem(
                                    icon: Icons.lock_outline_rounded,
                                    title: 'Kebijakan Privasi',
                                    onTap: () {
                                      _showInfoMessage(
                                        'Halaman kebijakan privasi '
                                        'belum tersedia.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          Center(
                            child: Text(
                              'RacikAI v1.0.0',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProfilePageHeader extends StatelessWidget {
  const _ProfilePageHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 29,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
            color: colors.onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Kelola akun dan preferensi RacikAI.',
          style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String name;
  final String email;
  final bool isPremium;
  final VoidCallback onEdit;

  const _AccountCard({
    required this.name,
    required this.email,
    required this.isPremium,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.person_rounded,
                  size: 31,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPremium
                      ? colors.secondaryContainer
                      : colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.person_outline_rounded,
                      size: 14,
                      color: isPremium
                          ? colors.secondary
                          : colors.onSurfaceVariant,
                    ),

                    const SizedBox(width: 5),

                    Text(
                      isPremium ? 'Premium' : 'Free',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isPremium
                            ? colors.onSecondaryContainer
                            : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: const Text('Edit profil'),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.auto_awesome_rounded,
                  size: 21,
                  color: colors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.planName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isPremium
                          ? 'Paket ${subscription.planPeriod}'
                          : 'Paket yang sedang digunakan',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
            ],
          ),

          if (!isPremium) ...[
            const SizedBox(height: 14),

            AnimatedBuilder(
              animation: UsageController.instance,
              builder: (context, _) {
                final usage = UsageController.instance.aiUsage;

                final progress = (usage / UsageController.freeAiLimit)
                    .clamp(0.0, 1.0)
                    .toDouble();

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Pertanyaan AI hari ini',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),

                        Text(
                          '$usage / '
                          '${UsageController.freeAiLimit}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: colors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          const SizedBox(height: 16),

          _PlanFeatureRow(
            icon: Icons.auto_awesome_rounded,
            text: isPremium
                ? 'Pertanyaan AI tanpa batas'
                : '${UsageController.freeAiLimit} '
                      'pertanyaan AI per hari',
          ),

          const SizedBox(height: 8),

          _PlanFeatureRow(
            icon: Icons.favorite_border_rounded,
            text: isPremium
                ? 'Simpan resep tanpa batas'
                : 'Maksimal 10 resep tersimpan',
          ),

          const SizedBox(height: 8),

          _PlanFeatureRow(
            icon: Icons.calendar_month_outlined,
            text: isPremium
                ? 'Meal Planner aktif'
                : 'Meal Planner tersedia di Premium',
          ),

          if (!isPremium) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.push('/premium');
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Lihat Premium'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
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
        Icon(icon, size: 17, color: colors.primary),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        child,
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],

            if (i != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 52, right: 16),
                child: Divider(height: 1, color: colors.outlineVariant),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Icon(icon, size: 20, color: colors.primary),
              ),

              const SizedBox(width: 14),

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
                const SizedBox(width: 10),

                Flexible(
                  child: Text(
                    trailingText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],

              const SizedBox(width: 7),

              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.onSurfaceVariant.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
