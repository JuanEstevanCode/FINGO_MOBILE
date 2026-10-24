import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../../../core/widgets/fingo_brand.dart';
import '../../movements/models/financial_movement.dart';
import '../../movements/services/movement_service.dart';
import '../../movements/widgets/movement_form.dart';
import '../../../core/api/api_client.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.onOpenHistory});

  final VoidCallback? onOpenHistory;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MovementService _movementService = MovementService();
  bool _loading = true;

  @override
  void initState() { super.initState(); _refresh(); }

  Future<void> _refresh() async {
    try { await _movementService.load(); } on ApiException catch (_) {}
    if (mounted) setState(() => _loading = false);
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

  Future<void> _openMovementForm(MovementType type) async {
    final movement = await showModalBottomSheet<FinancialMovement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FingoColors.surface,
      builder: (_) => MovementForm(initialType: type),
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
        title: const FingoBrand(compact: true),
        actions: [
          IconButton(
            onPressed: null,
            tooltip: 'Notificaciones (próximamente)',
            icon: const Icon(Icons.notifications_none_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text('Inicio', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text('Tus finanzas, más claras.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            if (_loading) const LinearProgressIndicator(),
            _buildBalanceCard(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 18),
            if (movements.isNotEmpty) _buildChart(movements),
            if (movements.isNotEmpty) const SizedBox(height: 18),
            _buildQuickActions(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Últimos movimientos', style: Theme.of(context).textTheme.titleLarge),
                Text('${movements.length} registros', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            if (movements.isEmpty) _buildEmptyState() else ...movements.take(3).map(_buildMovementTile),
            if (movements.length > 3)
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: widget.onOpenHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('Ver historial completo en Movimientos'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [FingoColors.primary, Color(0xFF10543D)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Balance total', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text(_formatMoney(_movementService.balance), style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Ingresos menos gastos registrados', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Widget _buildSummary() {
    return Row(children: [
      Expanded(child: _summaryCard('Ingresos', _movementService.totalIncome, FingoColors.income, Icons.south_west)),
      const SizedBox(width: 12),
      Expanded(child: _summaryCard('Gastos', _movementService.totalExpenses, FingoColors.expense, Icons.north_east)),
    ]);
  }

  Widget _summaryCard(String label, double amount, Color color, IconData icon) {
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 12), Text(label, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 4), FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(_formatMoney(amount), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 17)))])));
  }

  Widget _buildChart(List<FinancialMovement> movements) {
    final data = movements.take(6).toList().reversed.toList();
    final maxAmount = data.fold<double>(0, (max, item) => item.amount > max ? item.amount : max);
    return Card(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Comportamiento reciente', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 16), SizedBox(height: 110, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: data.map((movement) { final height = maxAmount == 0 ? 0.0 : 78 * movement.amount / maxAmount; final color = movement.type == MovementType.income ? FingoColors.income : FingoColors.expense; return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(height: height.clamp(8, 78), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))), const SizedBox(height: 6), Icon(movement.type == MovementType.income ? Icons.add : Icons.remove, size: 14, color: color)]))); }).toList()))])));
  }

  Widget _buildQuickActions() {
    return Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: () => _openMovementForm(MovementType.income), icon: const Icon(Icons.add_circle_outline), label: const Text('Registrar ingreso'), style: OutlinedButton.styleFrom(foregroundColor: FingoColors.income, padding: const EdgeInsets.symmetric(vertical: 14)))),
      const SizedBox(width: 12),
      Expanded(child: OutlinedButton.icon(onPressed: () => _openMovementForm(MovementType.expense), icon: const Icon(Icons.remove_circle_outline), label: const Text('Registrar gasto'), style: OutlinedButton.styleFrom(foregroundColor: FingoColors.expense, padding: const EdgeInsets.symmetric(vertical: 14)))),
    ]);
  }

  Widget _buildEmptyState() {
    return Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18), child: Column(children: [const Icon(Icons.insights_outlined, size: 40, color: FingoColors.accent), const SizedBox(height: 10), Text('Aún no tienes movimientos', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), Text('Registra un ingreso o gasto para ver tu resumen.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)])));
  }

  Widget _buildMovementTile(FinancialMovement movement) {
    final income = movement.type == MovementType.income;
    final color = income ? FingoColors.income : FingoColors.expense;
    return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.14), child: Icon(income ? Icons.south_west : Icons.north_east, color: color)), title: Text(movement.category), subtitle: Text(movement.description.isEmpty ? (income ? 'Ingreso' : 'Gasto') : movement.description), trailing: Text('${income ? '+' : '-'}${_formatMoney(movement.amount)}', style: TextStyle(color: color, fontWeight: FontWeight.w700))));
  }
}
