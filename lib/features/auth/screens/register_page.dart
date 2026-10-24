import 'package:flutter/material.dart';
import '../../../core/api/api_client.dart';

import '../../../core/widgets/fingo_brand.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _birthDateController = TextEditingController();
  DateTime? _birthDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _registerLocally() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.request('POST', '/auth/registro', authenticated: false, body: {
        'nombre': _nameController.text.trim(), 'correo': _emailController.text.trim(),
        'fecha_nacimiento': '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}', 'password': _passwordController.text,
      });
      await ApiClient.instance.saveProfile(name: _nameController.text.trim(), email: _emailController.text.trim(), birthDate: '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}');
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta creada. Inicia sesión para continuar.'))); Navigator.pop(context); }
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } finally { if (mounted) setState(() => _submitting = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FingoBrand(compact: true),
                    const SizedBox(height: 32),
                    Text('Crea tu cuenta', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text('Empieza a tomar el control de tu dinero.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 26),
                    TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)), validator: (value) => value == null || value.trim().length < 2 ? 'Ingresa tu nombre' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _birthDateController, readOnly: true, decoration: const InputDecoration(labelText: 'Fecha de nacimiento', prefixIcon: Icon(Icons.calendar_today_outlined)), onTap: () async { final now = DateTime.now(); final date = await showDatePicker(context: context, initialDate: DateTime(now.year - 18), firstDate: DateTime(1900), lastDate: now); if (date != null && mounted) setState(() { _birthDate = date; _birthDateController.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'; }); }, validator: (_) => _birthDate == null ? 'Selecciona tu fecha de nacimiento' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.mail_outline)), validator: (value) => value == null || !value.contains('@') ? 'Ingresa un correo válido' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline)), validator: (value) => value == null || value.length < 6 ? 'Usa al menos 6 caracteres' : null),
                    const SizedBox(height: 14),
                    TextFormField(controller: _confirmationController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirmar contraseña', prefixIcon: Icon(Icons.verified_user_outlined)), validator: (value) => value != _passwordController.text ? 'Las contraseñas no coinciden' : null),
                    const SizedBox(height: 24),
                    SizedBox(height: 52, child: ElevatedButton(onPressed: _submitting ? null : _registerLocally, child: _submitting ? const CircularProgressIndicator() : const Text('Crear cuenta'))),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ya tengo una cuenta')),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
