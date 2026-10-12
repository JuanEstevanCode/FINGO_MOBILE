import '../models/financial_movement.dart';

/// Administra los movimientos financieros en memoria.
class MovementService {
  final List<FinancialMovement> _movements = [];

  /// Devuelve una vista de solo lectura de los movimientos.
  List<FinancialMovement> get movements => List.unmodifiable(_movements);

  /// Calcula la suma de los ingresos.
  double get totalIncome => _movements
      .where((movement) => movement.type == MovementType.income)
      .fold(0.0, (total, movement) => total + movement.amount);

  /// Calcula la suma de los gastos.
  double get totalExpenses => _movements
      .where((movement) => movement.type == MovementType.expense)
      .fold(0.0, (total, movement) => total + movement.amount);

  /// Calcula el balance disponible.
  double get balance => totalIncome - totalExpenses;

  /// Registra un movimiento al principio de la lista.
  void addMovement(FinancialMovement movement) {
    _movements.insert(0, movement);
  }

  /// Actualiza un movimiento existente.
  bool updateMovement(FinancialMovement original, FinancialMovement updated) {
    final index = _movements.indexOf(original);

    if (index == -1) return false;

    _movements[index] = updated;
    return true;
  }

  /// Elimina un movimiento existente.
  bool deleteMovement(FinancialMovement movement) {
    return _movements.remove(movement);
  }
}
