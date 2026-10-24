import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../../../core/widgets/fingo_brand.dart';
import '../models/budget.dart';
import '../services/demo_budget_service.dart';
import 'budget_detail_page.dart';
import 'budget_form_page.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _service = DemoBudgetService();
  final bool _loading = false;
  bool _showError = false;

  Future<void> _createOrEdit([Budget? budget]) async {
    final result = await Navigator.push<Budget>(context, MaterialPageRoute(builder: (_) => BudgetFormPage(budget: budget)));
    if (!mounted || result == null) return;
    setState(() => budget == null ? _service.add(result) : _service.update(budget, result));
  }

  Future<void> _delete(Budget budget) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Eliminar presupuesto'), content: Text('¿Eliminar “${budget.name}”? Esta acción solo afecta los datos locales de demostración.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')), TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar'))]));
    if (confirmed == true && mounted) setState(() => _service.remove(budget));
  }

  @override
  Widget build(BuildContext context) {
    final budgets = _service.budgets;
    return Scaffold(
      appBar: AppBar(title: const FingoBrand(compact: true)),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _createOrEdit(), icon: const Icon(Icons.add), label: const Text('Nuevo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            Text('Presupuestos', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Planifica tus límites y sigue tu progreso.', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: FingoColors.elevatedSurface, borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.info_outline, color: FingoColors.accent), const SizedBox(width: 10), Expanded(child: Text('Datos de demostración local. La API se conectará en otra etapa.', style: Theme.of(context).textTheme.bodySmall))])),
            const SizedBox(height: 20),
            if (_showError) _StateMessage(icon: Icons.error_outline, title: 'No se pudieron cargar los presupuestos', action: TextButton(onPressed: () => setState(() => _showError = false), child: const Text('Reintentar')))
            else if (_loading) const _StateMessage(icon: Icons.hourglass_empty, title: 'Cargando presupuestos…')
            else if (budgets.isEmpty) _StateMessage(icon: Icons.account_balance_wallet_outlined, title: 'Aún no tienes presupuestos', action: ElevatedButton(onPressed: () => _createOrEdit(), child: const Text('Crear el primero')))
            else ...budgets.map(_budgetCard),
          ],
        ),
      ),
    );
  }

  Widget _budgetCard(Budget budget) {
    final over = budget.remaining < 0;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetDetailPage(budget: budget))), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(budget.name, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text(budget.period, style: Theme.of(context).textTheme.bodySmall)])), PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') _createOrEdit(budget); if (value == 'delete') _delete(budget); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))])]), const SizedBox(height: 16), LinearProgressIndicator(value: budget.progress, minHeight: 8, borderRadius: BorderRadius.circular(8), color: over ? FingoColors.expense : FingoColors.accent, backgroundColor: FingoColors.border), const SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$ ${budget.spent.toStringAsFixed(0)} gastados', style: const TextStyle(fontSize: 13)), Text('de \$ ${budget.amount.toStringAsFixed(0)}', style: TextStyle(color: over ? FingoColors.expense : FingoColors.textSecondary, fontSize: 13))])])))
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.title, this.action});
  final IconData icon;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20), child: Column(children: [Icon(icon, size: 42, color: FingoColors.accent), const SizedBox(height: 12), Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge), if (action != null) ...[const SizedBox(height: 14), action!]])));
}
