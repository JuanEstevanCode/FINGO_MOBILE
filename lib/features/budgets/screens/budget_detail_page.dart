import 'package:flutter/material.dart';

import '../../../core/theme/fingo_theme.dart';
import '../models/budget.dart';

class BudgetDetailPage extends StatelessWidget {
  const BudgetDetailPage({super.key, required this.budget});

  final Budget budget;

  String _money(double value) => '\$ ${value.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final over = budget.remaining < 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del presupuesto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(budget.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(budget.period, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: budget.progress, minHeight: 9, borderRadius: BorderRadius.circular(8), color: over ? FingoColors.expense : FingoColors.accent, backgroundColor: FingoColors.border),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${_money(budget.spent)} gastados'), Text('de ${_money(budget.amount)}')]),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [Icon(over ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: over ? FingoColors.expense : FingoColors.accent, size: 30), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(over ? 'Presupuesto excedido' : 'Disponible', style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 4), Text(over ? 'Has superado el lÃ­mite por ${_money(budget.remaining.abs())}.' : 'Te quedan ${_money(budget.remaining)} para este periodo.', style: Theme.of(context).textTheme.bodySmall)]))]))),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}
