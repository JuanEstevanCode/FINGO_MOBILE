class FinancialCategory {
  const FinancialCategory({required this.id, required this.name, required this.type, required this.isDefault, required this.active});
  final int id;
  final String name;
  final String type;
  final bool isDefault;
  final bool active;

  factory FinancialCategory.fromApi(List<dynamic> row) => FinancialCategory(
    id: (row[0] as num).toInt(), name: row[1].toString(), type: row[2].toString(),
    isDefault: row[3] == true, active: row[4] == true,
  );
}
