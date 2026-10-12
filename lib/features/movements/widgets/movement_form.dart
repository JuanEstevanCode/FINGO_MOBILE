import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../models/financial_movement.dart';

/// Formulario para registrar un ingreso o un gasto.

class MovementForm extends StatefulWidget {
  const MovementForm({super.key, this.initialMovement});

  final FinancialMovement? initialMovement;

  @override
  State<MovementForm> createState() => _MovementFormState();
}

class _MovementFormState extends State<MovementForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late MovementType _type;
  String? _category;
  late DateTime? _date;

  @override
  void initState() {
    super.initState();

    final movement = widget.initialMovement;

    _type = movement?.type ?? MovementType.expense;
    _category = movement?.category;
    _date = movement?.date ?? DateTime.now();

    if (movement != null) {
      _amountController.text = movement.amount.toStringAsFixed(2);
      _descriptionController.text = movement.description;
    }
  }

  final Map<MovementType, List<String>> _categories = {
    MovementType.income: ['Salario', 'Ventas', 'Inversiones', 'Otros ingresos'],
    MovementType.expense: [
      'Alimentación',
      'Transporte',
      'Vivienda',
      'Salud',
      'Entretenimiento',
      'Otros gastos',
    ],
  };

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona la fecha del movimiento',
    );

    if (selectedDate != null && mounted) {
      setState(() => _date = selectedDate);
    }
  }

  void _saveMovement() {
    if (!_formKey.currentState!.validate()) return;

    if (_date == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
      return;
    }

    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    Navigator.of(context).pop(
      FinancialMovement(
        type: _type,
        amount: amount,
        category: _category!,
        date: _date!,
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FingoColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                widget.initialMovement == null
                    ? 'Nuevo movimiento'
                    : 'Editar movimiento',
              ),
              const SizedBox(height: 20),
              SegmentedButton<MovementType>(
                segments: const [
                  ButtonSegment(
                    value: MovementType.expense,
                    label: Text('Gasto'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: MovementType.income,
                    label: Text('Ingreso'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    _category = null;
                  });
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  hintText: 'Ej. 25000 o 25000.50',
                ),
                validator: (value) {
                  final normalized = value?.trim().replaceAll(',', '.');

                  if (normalized == null || normalized.isEmpty) {
                    return 'Ingresa el monto';
                  }

                  final amount = double.tryParse(normalized);

                  if (amount == null || !amount.isFinite || amount <= 0) {
                    return 'Ingresa un monto válido mayor que cero';
                  }

                  if (normalized.split('.').length > 2 ||
                      (normalized.contains('.') &&
                          normalized.split('.').last.length > 2)) {
                    return 'Usa máximo dos decimales';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories[_type]!
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(
                    _date == null
                        ? 'Selecciona una fecha'
                        : '${_date!.day.toString().padLeft(2, '0')}/'
                              '${_date!.month.toString().padLeft(2, '0')}/'
                              '${_date!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLength: 200,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: '¿En qué consiste el movimiento?',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if ((value?.length ?? 0) > 200) {
                    return 'Máximo 200 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveMovement,
                  child: Text(
                      widget.initialMovement == null
                          ? 'Guardar movimiento'
                          : 'Guardar cambios',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
