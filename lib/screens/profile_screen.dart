import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: backgroundColor,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                10,
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

                      _AccountCard(
                        name: name,
                        email: email,
                        onEdit: _openEditProfile,
                      ),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RacikAI',
                    style: TextStyle(
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Aplikasi Resep Makanan',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/racikai_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 1.5,
          color: colors.outlineVariant,
        ),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;

  const _AccountCard({
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 28,
                  color: colors.onPrimary,
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
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: colors.onPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colors.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: colors.onPrimary.withOpacity(0.9),
              ),
            ],
          ),
        ),
      ),
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
            color: colors.primary,
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
                padding: const EdgeInsets.only(left: 62, right: 16),
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
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),

              const SizedBox(width: 12),

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
