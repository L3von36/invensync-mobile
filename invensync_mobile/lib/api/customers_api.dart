import '../api/api_client.dart';
import '../models/customer.dart';
import '../models/supplier.dart';
import '../models/pagination.dart';

class CustomersApi {
  final ApiClient _client;
  CustomersApi(this._client);

  Future<PaginatedResponse<Customer>> getCustomers({
    int page = 1, int limit = 20, String? search, String? shopId,
  }) async {
    final qp = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null) qp['search'] = search;
    if (shopId != null) qp['shopId'] = shopId;
    final r = await _client.get('/api/customers', queryParameters: qp);
    return PaginatedResponse.fromJson(
        r.data as Map<String, dynamic>, Customer.fromJson);
  }

  Future<Customer> createCustomer(Map<String, dynamic> data) async {
    final r = await _client.post('/api/customers', data: data);
    return Customer.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> data) async {
    final r = await _client.put('/api/customers/$id', data: data);
    return Customer.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Customer>> getAllForSync({
    required String orgId, String? updatedSince, int page = 1,
  }) async {
    final qp = <String, dynamic>{'limit': 500, 'page': page};
    if (updatedSince != null) qp['updatedSince'] = updatedSince;
    final r = await _client.get('/api/customers', queryParameters: qp);
    return ((r.data as Map<String, dynamic>)['data'] as List<dynamic>?)
            ?.map((e) => Customer.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
  }
}

class SuppliersApi {
  final ApiClient _client;
  SuppliersApi(this._client);

  Future<PaginatedResponse<Supplier>> getSuppliers({
    int page = 1, int limit = 20, String? search,
  }) async {
    final qp = <String, dynamic>{'page': page, 'limit': limit};
    if (search != null) qp['search'] = search;
    final r = await _client.get('/api/suppliers', queryParameters: qp);
    return PaginatedResponse.fromJson(
        r.data as Map<String, dynamic>, Supplier.fromJson);
  }

  Future<Supplier> createSupplier(Map<String, dynamic> data) async {
    final r = await _client.post('/api/suppliers', data: data);
    return Supplier.fromJson(r.data as Map<String, dynamic>);
  }

  Future<List<Supplier>> getAllForSync({
    required String orgId, String? updatedSince, int page = 1,
  }) async {
    final qp = <String, dynamic>{'limit': 500, 'page': page};
    if (updatedSince != null) qp['updatedSince'] = updatedSince;
    final r = await _client.get('/api/suppliers', queryParameters: qp);
    return ((r.data as Map<String, dynamic>)['data'] as List<dynamic>?)
            ?.map((e) => Supplier.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
  }
}