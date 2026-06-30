import '../api/api_client.dart';
import '../models/sale.dart';
import '../models/pagination.dart';

class SalesApi {
  final ApiClient _client;

  SalesApi(this._client);

  Future<PaginatedResponse<Sale>> getSales({
    int page = 1,
    int limit = 20,
    String? status,
    String? paymentMethod,
    String? shopId,
    String? customerId,
    String? fromDate,
    String? toDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page, 'limit': limit,
    };
    if (status != null) queryParams['status'] = status;
    if (paymentMethod != null) queryParams['paymentMethod'] = paymentMethod;
    if (shopId != null) queryParams['shopId'] = shopId;
    if (customerId != null) queryParams['customerId'] = customerId;
    if (fromDate != null) queryParams['fromDate'] = fromDate;
    if (toDate != null) queryParams['toDate'] = toDate;

    final response = await _client.get('/api/sales',
        queryParameters: queryParams);
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>, Sale.fromJson,
    );
  }

  Future<Sale> getSale(String id) async {
    final response = await _client.get('/api/sales/$id');
    return Sale.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Sale> createSale(Map<String, dynamic> data) async {
    final response = await _client.post('/api/sales', data: data);
    return Sale.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Sale>> getAllForSync({
    required String organizationId,
    String? updatedSince,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': 500, 'page': page,
    };
    if (updatedSince != null) queryParams['updatedSince'] = updatedSince;
    final response = await _client.get('/api/sales',
        queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>?)
            ?.map((e) => Sale.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
}