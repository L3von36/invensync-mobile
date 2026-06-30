import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/stock_movement.dart';

class InventoryApi {
  final ApiClient _client;

  InventoryApi(this._client);

  Future<List<StockMovement>> getMovements({
    int page = 1,
    int limit = 50,
    String? productId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (productId != null) queryParams['productId'] = productId;
    if (type != null) queryParams['type'] = type;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final response = await _client.get(
      '/inventory/movements',
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StockMovement> adjustStock(Map<String, dynamic> data) async {
    final response = await _client.post('/inventory/adjust', data: data);
    return StockMovement.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getStockSummary({String? shopId}) async {
    final queryParams = <String, dynamic>{};
    if (shopId != null) queryParams['shopId'] = shopId;

    final response = await _client.get(
      '/inventory/summary',
      queryParameters: queryParams,
    );
    return response.data as Map<String, dynamic>;
  }
}