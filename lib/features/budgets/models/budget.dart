class Budget {
  Budget({required this.name, required this.amount, required this.spent, required this.period, this.id});

  final String? id;
  String name;
  double amount;
  double spent;
  String period;

  double get remaining => amount - spent;
  double get progress => amount == 0 ? 0 : (spent / amount).clamp(0, 1).toDouble();
}
