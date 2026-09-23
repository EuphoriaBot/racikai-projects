import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../controllers/subscription_controller.dart';
import '../controllers/theme_controller.dart';
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui.')),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final subscription = SubscriptionController.instance;
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: subscription,
      builder: (context, _) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountHeader(
                  name: name,
                  email: email,
                  isPremium: subscription.isPremium,
                  onEdit: _openEditProfile,
                ),

                const SizedBox(height: 18),

                _PlanOverviewCard(subscription: subscription),

                const SizedBox(height: 30),

                const _SectionTitle(title: 'Personalisasi'),

                const SizedBox(height: 10),

                _SettingsGroup(
                  children: [
                    _SettingsItem(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'Preferensi makanan',
                      trailingText: preference,
                      onTap: _openEditProfile,
                    ),
                    _SettingsItem(
                      icon: Icons.palette_outlined,
                      title: 'Tampilan',
                      trailingText: ThemeController.instance.modeLabel,
                      onTap: () {
                        _showThemePicker(context);
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.language_rounded,
                      title: 'Bahasa',
                      trailingText: 'Indonesia',
                      onTap: () {
                        _showInfoMessage(
                          'Saat ini RacikAI menggunakan Bahasa Indonesia.',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                const _SectionTitle(title: 'Pengaturan'),

                const SizedBox(height: 10),

                _SettingsGroup(
                  children: [
                    _SettingsItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      onTap: () {
                        _showInfoMessage(
                          'Pengaturan notifikasi belum tersedia.',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                const _SectionTitle(title: 'Informasi'),

                const SizedBox(height: 10),

                _SettingsGroup(
                  children: [
                    _SettingsItem(
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
                    _SettingsItem(
                      icon: Icons.lock_outline_rounded,
                      title: 'Kebijakan Privasi',
                      onTap: () {
                        _showInfoMessage(
                          'Halaman kebijakan privasi belum tersedia.',
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Center(
                  child: Text(
                    'RacikAI v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.65),
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

class _AccountHeader extends StatelessWidget {
  final String name;
  final String email;
  final bool isPremium;
  final VoidCallback onEdit;

  const _AccountHeader({
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
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.person_rounded,
              size: 34,
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

                const SizedBox(height: 3),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPremium
                        ? colors.primaryContainer
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
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
                            ? colors.primary
                            : colors.onSurfaceVariant,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        isPremium ? 'Premium' : 'Free',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPremium
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Material(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onEdit,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
      ),
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
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],

            if (i != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 53, right: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.65),
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Icon(icon, size: 21, color: colors.primary),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
              ),

              if (trailingText != null) ...[
                const SizedBox(width: 12),

                Text(
                  trailingText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: colors.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
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
                    'Tampilan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Pilih tema yang paling nyaman digunakan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isPremium
              ? colors.primary.withValues(alpha: 0.6)
              : colors.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.auto_awesome_rounded,
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
            ],
          ),

          if (!isPremium) ...[
            const SizedBox(height: 18),

            AnimatedBuilder(
              animation: UsageController.instance,
              builder: (context, _) {
                final usage = UsageController.instance.aiUsage;

                final progress = (usage / UsageController.freeAiLimit)
                    .clamp(0.0, 1.0)
                    .toDouble();

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Penggunaan AI hari ini',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurfaceVariant,
                              ),
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

                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colors.surface,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 18),

          _PlanFeatureRow(
            icon: Icons.auto_awesome_rounded,
            text: isPremium
                ? 'Pertanyaan AI tanpa batas'
                : '${UsageController.freeAiLimit} pertanyaan AI per hari',
          ),

          const SizedBox(height: 11),

          _PlanFeatureRow(
            icon: Icons.favorite_border_rounded,
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
                  context.push('/premium');
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Upgrade ke Premium'),
                style: FilledButton.styleFrom(
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
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: colors.primary,
                  ),

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
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: colors.primary),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
