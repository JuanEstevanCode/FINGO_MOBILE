import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../../../core/widgets/fingo_brand.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const FingoBrand(compact: true)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Perfil', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text('Ajustes provisionales de la aplicación.', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        Card(child: ListTile(leading: const CircleAvatar(backgroundColor: FingoColors.elevatedSurface, child: Icon(Icons.person_outline, color: FingoColors.accent)), title: const Text('Perfil local'), subtitle: const Text('La cuenta se conectará en una etapa posterior.'))),
        const SizedBox(height: 12),
        Card(child: Column(children: const [ListTile(leading: Icon(Icons.notifications_none_outlined), title: Text('Notificaciones'), trailing: Icon(Icons.chevron_right)), Divider(height: 1), ListTile(leading: Icon(Icons.palette_outlined), title: Text('Apariencia'), subtitle: Text('Modo oscuro activo'), trailing: Icon(Icons.chevron_right))])),
      ]),
    );
  }
}
