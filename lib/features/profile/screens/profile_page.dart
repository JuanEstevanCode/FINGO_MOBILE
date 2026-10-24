import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/theme/fingo_theme.dart';
import '../../../core/widgets/fingo_brand.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String?> _profile = const {};

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final profile = await ApiClient.instance.readProfile();
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _logout() async {
    await ApiClient.instance.clearSession();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const FingoBrand(compact: true)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Card(
                child: Column(children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: FingoColors.elevatedSurface,
                      child: Icon(Icons.person_outline, color: FingoColors.accent),
                    ),
                    title: Text(_profile['name']?.isNotEmpty == true ? _profile['name']! : 'Usuario FINGO'),
                    subtitle: Text(_profile['email'] ?? 'Correo no disponible'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cake_outlined),
                    title: const Text('Fecha de nacimiento'),
                    subtitle: Text(_profile['birthDate'] ?? 'No disponible'),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Apariencia'),
                  subtitle: const Text('Modo oscuro activo'),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FingoColors.expense,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      );
}
