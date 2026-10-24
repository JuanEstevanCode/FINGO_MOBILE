import '../../../core/api/api_client.dart';
import '../models/budget.dart';

class BudgetService {
  Future<List<Budget>> list() async {
    final rows = await ApiClient.instance.request('GET', '/presupuestos/') as List;
    return rows.map((row) => Budget.fromApi(Map<String, dynamic>.from(row as Map))).toList();
  }

  Future<Budget> create(Map<String, dynamic> body) async => Budget.fromApi(
    Map<String, dynamic>.from(await ApiClient.instance.request('POST', '/presupuestos/', body: body) as Map),
  );

  Future<Budget> update(int id, Map<String, dynamic> body) async => Budget.fromApi(
    Map<String, dynamic>.from(await ApiClient.instance.request('PUT', '/presupuestos/$id', body: body) as Map),
  );

  Future<void> delete(int id) async => ApiClient.instance.request('DELETE', '/presupuestos/$id');
}
