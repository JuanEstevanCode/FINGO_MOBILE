import '../models/financial_movement.dart';
import '../../../core/api/api_client.dart';
import '../models/category.dart';

/// Administra los movimientos financieros en memoria.
class MovementService {
  MovementService._();

  static final MovementService instance = MovementService._();

  factory MovementService() => instance;

  final List<FinancialMovement> _movements = [];
  final List<FinancialCategory> _categories = [];

  List<FinancialCategory> get categories => List.unmodifiable(_categories);

  Future<void> load() async {
    final rows = await ApiClient.instance.request('GET', '/movimientos/', query: {'limite': '100', 'desplazamiento': '0'}) as List;
    _movements..clear()..addAll(rows.map((row) => FinancialMovement.fromApi(List<dynamic>.from(row as List))));
  }

  Future<void> loadCategories() async {
    final rows = await ApiClient.instance.request('GET', '/categorias/') as List;
    _categories..clear()..addAll(rows.map((row) => FinancialCategory.fromApi(List<dynamic>.from(row as List))));
  }

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
  Future<void> addMovement(FinancialMovement movement) async {
    final result = await ApiClient.instance.request('POST', '/movimientos/', body: movement.toApiJson()) as Map;
    movement.id = (result['id'] as num).toInt();
    _movements.insert(0, movement);
  }

  /// Actualiza un movimiento existente.
  Future<bool> updateMovement(FinancialMovement original, FinancialMovement updated) async {
    final index = _movements.indexOf(original);

    if (index == -1 || original.id == null) return false;

    await ApiClient.instance.request('PUT', '/movimientos/${original.id}', body: updated.toApiJson());
    updated.id = original.id;

    _movements[index] = updated;
    return true;
  }

  /// Elimina un movimiento existente.
  Future<bool> deleteMovement(FinancialMovement movement) async {
    if (movement.id == null) return false;
    await ApiClient.instance.request('DELETE', '/movimientos/${movement.id}');
    return _movements.remove(movement);
  }
}
