class Budget {
  Budget({required this.name, required this.amount, required this.spent, required this.period, this.categoryId = 0, this.startDate = '', this.endDate = '', this.id, this.periodType = 'mensual', this.status = 'normal'});

  final int? id;
  final String name;
  final double amount;
  final double spent;
  final String period;
  final int categoryId;
  final String startDate;
  final String endDate;
  final String periodType;
  final String status;

  factory Budget.fromApi(Map<String, dynamic> json) => Budget(
    id: (json['id'] as num).toInt(), name: json['categoria_nombre'].toString(),
    amount: double.parse(json['monto_limite'].toString()), spent: double.parse(json['gasto_acumulado'].toString()),
    period: '${json['fecha_inicio']} – ${json['fecha_fin']}', categoryId: (json['categoria_id'] as num).toInt(),
    startDate: json['fecha_inicio'].toString(), endDate: json['fecha_fin'].toString(),
    periodType: json['tipo_periodo'].toString(), status: json['estado'].toString(),
  );

  Map<String, dynamic> toApiJson() => {'categoria_id': categoryId, 'tipo_periodo': periodType, 'fecha_inicio': startDate, 'fecha_fin': endDate, 'monto_limite': amount.toStringAsFixed(2)};

  double get remaining => amount - spent;
  double get progress => amount == 0 ? 0 : (spent / amount).clamp(0, 1).toDouble();
}
