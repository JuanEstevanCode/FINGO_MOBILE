import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../movements/models/category.dart';
import '../../movements/services/movement_service.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';
import '../widgets/category_name_dialog.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({super.key, this.budget});
  final Budget? budget;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _service = BudgetService();
  List<FinancialCategory> _categories = [];
  int? _categoryId;
  late DateTime _start;
  late DateTime _end;
  late String _periodType;
  bool _loadingCategories = true;
  bool _saving = false;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final budget = widget.budget;
    _start = budget == null ? DateTime(now.year, now.month) : DateTime.parse(budget.startDate);
    _end = budget == null ? DateTime(now.year, now.month + 1, 0) : DateTime.parse(budget.endDate);
    _periodType = budget?.periodType ?? 'mensual';
    _categoryId = budget?.categoryId;
    _amountController.text = budget?.amount.toStringAsFixed(2) ?? '';
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      await MovementService.instance.loadCategories();
      if (!mounted) return;
      setState(() {
        _categories = MovementService.instance.categories
            .where((category) => category.active && category.type == 'gasto')
            .toList();
        _categoryError = null;
        _loadingCategories = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _categoryError = error.message;
        _loadingCategories = false;
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _selectDates() async {
    final dates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (dates == null || !mounted) return;
    setState(() {
      _start = dates.start;
      _end = dates.end;
      _periodType = 'personalizado';
    });
  }

  Future<void> _addCategory() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CategoryNameDialog(),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;

    try {
      final response = await ApiClient.instance.request(
        'POST',
        '/categorias/',
        body: {'nombre': name.trim(), 'tipo': 'gasto'},
      ) as Map;
      final id = (response['id'] as num).toInt();
      if (!mounted) return;
      await MovementService.instance.loadCategories();
      if (!mounted) return;
      setState(() {
        _categories = MovementService.instance.categories
            .where((category) => category.active && category.type == 'gasto')
            .toList();
        _categoryId = id;
      });
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    final amount = double.parse(
      _amountController.text.trim().replaceAll(',', '.'),
    );
    final body = <String, dynamic>{
      'categoria_id': _categoryId,
      'tipo_periodo': _periodType,
      'fecha_inicio': _formatDate(_start),
      'fecha_fin': _formatDate(_end),
      'monto_limite': amount.toStringAsFixed(2),
    };
    try {
      final saved = widget.budget == null
          ? await _service.create(body)
          : await _service.update(widget.budget!.id!, body);
      if (mounted) Navigator.pop(context, saved);
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.budget == null
              ? 'Nuevo presupuesto'
              : 'Editar presupuesto'),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Elige una categoría de gasto y define tu límite.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                if (_loadingCategories)
                  const Center(child: CircularProgressIndicator())
                else if (_categoryError != null)
                  TextButton(
                    onPressed: _loadCategories,
                    child: Text('Error: $_categoryError. Reintentar'),
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Categoría de gasto'),
                    items: [
                      ..._categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (id) => setState(() => _categoryId = id),
                    validator: (id) => id == null || id < 1
                        ? 'Selecciona una categoría'
                        : null,
                  ),
                if (!_loadingCategories && _categoryError == null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addCategory,
                      icon: const Icon(Icons.add),
                      label: const Text('Añadir categoría'),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Límite',
                    prefixText: '\$ ',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(
                      value?.trim().replaceAll(',', '.') ?? '',
                    );
                    return amount == null || amount <= 0
                        ? 'Ingresa un monto mayor que cero'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _periodType,
                  decoration: const InputDecoration(labelText: 'Periodo'),
                  items: const [
                    DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                    DropdownMenuItem(
                      value: 'personalizado',
                      child: Text('Personalizado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    if (value == 'mensual') {
                      final now = DateTime.now();
                      setState(() {
                        _periodType = value;
                        _start = DateTime(now.year, now.month);
                        _end = DateTime(now.year, now.month + 1, 0);
                      });
                    } else {
                      setState(() => _periodType = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _selectDates,
                  icon: const Icon(Icons.date_range),
                  label: Text('${_formatDate(_start)} — ${_formatDate(_end)}'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving || _loadingCategories ? null : _save,
                    child: _saving
                        ? const CircularProgressIndicator()
                        : Text(widget.budget == null
                            ? 'Crear presupuesto'
                            : 'Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
