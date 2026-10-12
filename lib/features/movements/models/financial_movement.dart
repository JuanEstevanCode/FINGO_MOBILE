/// Tipos de movimientos financieros admitidos por FINGO.
enum MovementType { income, expense }

/// Representa un ingreso o gasto registrado por el usuario.
class FinancialMovement {
  FinancialMovement({
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
  });

  MovementType type;
  double amount;
  String category;
  DateTime date;
  String description;
}
