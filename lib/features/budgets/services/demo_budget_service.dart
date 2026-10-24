import '../models/budget.dart';

/// Fuente local de demostración. Será reemplazada por un repositorio API.
class DemoBudgetService {
  final List<Budget> _budgets = [
    Budget(id: 'demo-1', name: 'Alimentación', amount: 800000, spent: 520000, period: 'Este mes'),
    Budget(id: 'demo-2', name: 'Transporte', amount: 300000, spent: 185000, period: 'Este mes'),
    Budget(id: 'demo-3', name: 'Entretenimiento', amount: 250000, spent: 235000, period: 'Este mes'),
  ];

  List<Budget> get budgets => List.unmodifiable(_budgets);

  void add(Budget budget) => _budgets.insert(0, budget);

  void update(Budget original, Budget updated) {
    final index = _budgets.indexOf(original);
    if (index != -1) _budgets[index] = updated;
  }

  void remove(Budget budget) => _budgets.remove(budget);
}
