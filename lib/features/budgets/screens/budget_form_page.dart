import 'package:flutter/material.dart';

import '../models/budget.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({super.key, this.budget});

  final Budget? budget;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _spentController;
  String _period = 'Este mes';

  @override
  void initState() {
    super.initState();
    final budget = widget.budget;
    _nameController = TextEditingController(text: budget?.name);
    _amountController = TextEditingController(text: budget?.amount.toStringAsFixed(0));
    _spentController = TextEditingController(text: budget?.spent.toStringAsFixed(0));
    _period = budget?.period ?? _period;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _spentController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final spent = double.parse(_spentController.text.replaceAll(',', '.'));
    Navigator.pop(context, Budget(id: widget.budget?.id, name: _nameController.text.trim(), amount: amount, spent: spent, period: _period));
  }

  String? _validateMoney(String? value, {required bool allowZero}) {
    final amount = double.tryParse(value?.trim().replaceAll(',', '.') ?? '');
    if (amount == null || !amount.isFinite || (allowZero ? amount < 0 : amount <= 0)) return allowZero ? 'Ingresa un valor válido' : 'Ingresa un monto mayor que cero';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.budget != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar presupuesto' : 'Nuevo presupuesto')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(editing ? 'Actualiza los límites de tu presupuesto.' : 'Define un límite para organizar tus gastos.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 24),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.label_outline)), validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa un nombre' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Límite del presupuesto', prefixText: '\$ ', prefixIcon: Icon(Icons.account_balance_wallet_outlined)), validator: (value) => _validateMoney(value, allowZero: false)),
              const SizedBox(height: 16),
              TextFormField(controller: _spentController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Gastado hasta ahora', prefixText: '\$ ', prefixIcon: Icon(Icons.payments_outlined)), validator: (value) => _validateMoney(value, allowZero: true)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(initialValue: _period, decoration: const InputDecoration(labelText: 'Periodo', prefixIcon: Icon(Icons.calendar_today_outlined)), items: const ['Esta semana', 'Este mes', 'Este año'].map((period) => DropdownMenuItem(value: period, child: Text(period))).toList(), onChanged: (value) => setState(() => _period = value ?? _period)),
              const SizedBox(height: 28),
              SizedBox(height: 52, child: ElevatedButton(onPressed: _save, child: Text(editing ? 'Guardar cambios' : 'Crear presupuesto'))),
            ],
          ),
        ),
      ),
    );
  }
}
