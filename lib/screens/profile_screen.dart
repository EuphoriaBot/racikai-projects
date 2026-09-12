import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const int aiUsage = 3;
    const int aiLimit = 5;

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

            // PROFILE HEADER
            const Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFFFFE8D5),
                    child: Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: Color(0xFFE8752E),
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    'Guest User',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Cook smarter with RacikAI ✨',
                    style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // FREE PLAN CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D5),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RacikAI Free',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF222222),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Paket kamu saat ini',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(Icons.auto_awesome, color: Color(0xFFE8752E)),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pertanyaan AI hari ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                        ),
                      ),
                      Text(
                        '$aiUsage / $aiLimit',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE8752E),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      value: aiUsage / aiLimit,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE8752E),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Halaman Premium akan dibuat pada step berikutnya.',
                            ),
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
                ],
              ),
            ),

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
                  applicationIcon: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8D5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFE8752E),
                    ),
                  ),
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
