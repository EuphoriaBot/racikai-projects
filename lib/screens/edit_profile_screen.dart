import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPreference;

  const EditProfileScreen({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPreference,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;

  late final TextEditingController emailController;

  String? selectedPreference;

  final List<String> preferences = [
    'Tidak ada',
    'Vegetarian',
    'Vegan',
    'Halal',
    'Rendah gula',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialName);

    emailController = TextEditingController(text: widget.initialEmail);

    selectedPreference = widget.initialPreference;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();

    super.dispose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }

    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  void saveProfile() {
    FocusScope.of(context).unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    context.pop<Map<String, String>>({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'preference': selectedPreference ?? 'Tidak ada',
    });
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
          'Edit profil',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWide ? 24 : 16,
                12,
                isWide ? 24 : 16,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Perbarui informasi akun dan '
                          'preferensi makanan sesuai kebutuhanmu.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const _FormLabel(text: 'Informasi akun'),

                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isWide ? 20 : 14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: nameController,
                                textInputAction: TextInputAction.next,
                                validator: validateName,
                                decoration: const InputDecoration(
                                  labelText: 'Nama',
                                  hintText: 'Masukkan nama kamu',
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: validateEmail,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  hintText: 'contoh@email.com',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const _FormLabel(text: 'Preferensi makanan'),

                        const SizedBox(height: 10),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isWide ? 20 : 14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedPreference,
                            decoration: const InputDecoration(
                              labelText: 'Pilih preferensi',
                              prefixIcon: Icon(Icons.restaurant_menu_outlined),
                            ),
                            items: preferences.map((preference) {
                              return DropdownMenuItem(
                                value: preference,
                                child: Text(preference),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPreference = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Pilih preferensi makanan';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: saveProfile,
                            icon: const Icon(Icons.check_rounded),
                            label: const Text('Simpan perubahan'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: colors.primary,
      ),
    );
  }
}
