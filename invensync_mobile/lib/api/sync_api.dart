import '../api/api_client.dart';
import '../models/dashboard.dart';
import '../models/stock_movement.dart';
import '../models/product.dart';

class DashboardApi {
  final ApiClient _client;
  DashboardApi(this._client);

  Future<DashboardData> getDashboard({String? period}) async {
    final qp = <String, dynamic>{};
    if (period != null) qp['period'] = period;
    final r = await _client.get('/api/dashboard', queryParameters: qp);
    return DashboardData.fromJson(r.data as Map<String, dynamic>);
  }
}

class InventoryApi {
  final ApiClient _client;
  InventoryApi(this._client);

  Future<Map<String, dynamic>> getStats() async {
    final r = await _client.get('/api/inventory/stats');
    return r.data as Map<String, dynamic>;
  }

  Future<StockMovement> adjustStock(Map<String, dynamic> data) async {
    final r = await _client.post('/api/inventory/adjust', data: data);
    return StockMovement.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Product>> getLowStockProducts() async {
    final r = await _client.get('/api/products', queryParameters: {
      'lowStock': 'true', 'limit': 50,
    });
    final data = r.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
  }

  Future<List<StockMovement>> getRecentMovements({int limit = 20}) async {
    final r = await _client.get('/api/inventory/movements',
        queryParameters: {'limit': limit});
    return ((r.data as Map<String, dynamic>)['data'] as List<dynamic>?)
            ?.map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
  }
}

class SyncApi {
  final ApiClient _client;
  SyncApi(this._client);

  Future<Map<String, dynamic>> getDelta({
    required String entity,
    required String updatedSince,
  }) async {
    final r = await _client.get('/api/sync/delta', queryParameters: {
      'entity': entity,
      'updatedSince': updatedSince,
    });
    return r.data as Map<String, dynamic>;
  }

  Future<void> pushOutboxItem(Map<String, dynamic> data) async {
    await _client.post('/api/sync/push', data: data);
  }
}