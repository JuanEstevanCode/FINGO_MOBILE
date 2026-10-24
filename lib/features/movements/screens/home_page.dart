import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../models/financial_movement.dart';
import '../services/movement_service.dart';
import '../widgets/movement_form.dart';
import '../../../core/api/api_client.dart';

/// Historial de movimientos registrados durante la sesión local.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MovementService _movementService = MovementService();
  bool _loading = true;
  String? _loadError;

  @override
  void initState() { super.initState(); _loadMovements(); }

  Future<void> _loadMovements() async {
    try { await _movementService.load(); if (mounted) setState(() { _loading = false; _loadError = null; }); }
    on ApiException catch (error) { if (mounted) setState(() { _loading = false; _loadError = error.message; }); }
  }

  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

    return '\$ $formattedInteger,${parts[1]}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _openMovementForm() async {
    final movement = await showModalBottomSheet<FinancialMovement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FingoColors.surface,
      builder: (_) => const MovementForm(),
    );

    if (movement == null || !mounted) return;

    try { await _movementService.addMovement(movement); if (mounted) setState(() {}); }
    on ApiException catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); return; }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento registrado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movements = _movementService.movements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              '${movements.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Historial financiero',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tus movimientos más recientes aparecen primero.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            _buildCompactBalance(),
            const SizedBox(height: 22),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_loadError != null) Center(child: Column(children: [Text(_loadError!), TextButton(onPressed: _loadMovements, child: const Text('Reintentar'))]))
            else if (movements.isEmpty)
              _buildEmptyState()
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Todos los movimientos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${movements.length} registros',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...movements.map(_buildMovementTile),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _openMovementForm,
                icon: const Icon(Icons.add),
                label: const Text('Registrar movimiento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBalance() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FingoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FingoColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: FingoColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined, color: FingoColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Balance total', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  _formatMoney(_movementService.balance),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          Text(
            'API',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: FingoColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: FingoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FingoColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 42, color: FingoColors.accent),
          SizedBox(height: 12),
          Text('Aún no tienes movimientos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Registra tu primer ingreso o gasto para comenzar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: FingoColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _editMovement(FinancialMovement movement) async {
    final updatedMovement = await showModalBottomSheet<FinancialMovement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FingoColors.surface,
      builder: (_) => MovementForm(initialMovement: movement),
    );

    if (updatedMovement == null || !mounted) return;

    final updated = await _movementService.updateMovement(movement, updatedMovement);
    if (!updated) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento actualizado correctamente')),
    );
  }

  Future<void> _confirmDeleteMovement(FinancialMovement movement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar movimiento'),
        content: const Text('¿Estás seguro de que deseas eliminar este movimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = await _movementService.deleteMovement(movement);
    if (!deleted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Movimiento eliminado correctamente')),
    );
  }

  Widget _buildMovementTile(FinancialMovement movement) {
    final isIncome = movement.type == MovementType.income;
    final color = isIncome ? FingoColors.income : FingoColors.expense;
    final sign = isIncome ? '+' : '-';
    final typeLabel = isIncome ? 'Ingreso' : 'Gasto';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FingoColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FingoColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isIncome ? Icons.south_west : Icons.north_east, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  movement.description.isEmpty ? typeLabel : '$typeLabel · ${movement.description}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: FingoColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(_formatDate(movement.date), style: const TextStyle(color: FingoColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$sign${_formatMoney(movement.amount)}', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              PopupMenuButton<String>(
                tooltip: 'Acciones del movimiento',
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') _editMovement(movement);
                  if (value == 'delete') _confirmDeleteMovement(movement);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 10), Text('Editar')])),
                  PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline), SizedBox(width: 10), Text('Eliminar')])),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
