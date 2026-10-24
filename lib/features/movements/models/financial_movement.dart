/// Tipos de movimientos financieros admitidos por FINGO.
enum MovementType { income, expense }

/// Representa un ingreso o gasto registrado por el usuario.
class FinancialMovement {
  FinancialMovement({
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.id,
    this.categoryId,
    this.description = '',
  });

  MovementType type;
  double amount;
  String category;
  DateTime date;
  String description;
  int? id;
  int? categoryId;
  String? apiType;

  factory FinancialMovement.fromApi(List<dynamic> row) => FinancialMovement(
    id: (row[0] as num).toInt(),
    type: row[1] == 'ingreso' ? MovementType.income : MovementType.expense,
    amount: double.parse(row[2].toString()),
    categoryId: (row[3] as num).toInt(),
    category: row[4].toString(),
    description: row[5]?.toString() ?? '',
    date: DateTime.parse(row[6].toString()),
  );

  Map<String, dynamic> toApiJson() => {
    'tipo': type == MovementType.income ? 'ingreso' : 'gasto',
    'monto': amount.toStringAsFixed(2),
    'categoria_id': categoryId,
    'descripcion': description.isEmpty ? null : description,
    'fecha': '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
  };
}
