import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/supplier.dart';

class SuppliersApi {
  final ApiClient _client;

  SuppliersApi(this._client);

  Future<List<Supplier>> getAll({
    int page = 1,
    int limit = 50,
    bool? activeOnly,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (activeOnly != null) queryParams['activeOnly'] = activeOnly;

    final response = await _client.get(
      '/suppliers',
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>;
    return items
        .map((e) => Supplier.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Supplier> getById(String id) async {
    final response = await _client.get('/suppliers/$id');
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Supplier> create(Map<String, dynamic> data) async {
    final response = await _client.post('/suppliers', data: data);
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Supplier> update(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/suppliers/$id', data: data);
    return Supplier.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _client.delete('/suppliers/$id');
  }
}