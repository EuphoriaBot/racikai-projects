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

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                'Informasi Profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Perbarui informasi dasar dan preferensi makananmu.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                validator: validateName,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  hintText: 'Masukkan nama kamu',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 18),

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

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: selectedPreference,
                decoration: const InputDecoration(
                  labelText: 'Preferensi makanan',
                  prefixIcon: Icon(Icons.restaurant_outlined),
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

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: saveProfile,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Perubahan'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
