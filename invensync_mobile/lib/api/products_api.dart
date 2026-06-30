import '../api/api_client.dart';
import '../models/product.dart';
import '../models/pagination.dart';

class ProductsApi {
  final ApiClient _client;

  ProductsApi(this._client);

  Future<PaginatedResponse<Product>> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    String? productTypeId,
    bool? isActive,
    String? shopId,
    bool? lowStock,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (search != null) queryParams['search'] = search;
    if (productTypeId != null) queryParams['productTypeId'] = productTypeId;
    if (isActive != null) queryParams['isActive'] = isActive;
    if (shopId != null) queryParams['shopId'] = shopId;
    if (lowStock == true) queryParams['lowStock'] = 'true';

    final response = await _client.get('/api/products',
        queryParameters: queryParams);
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      Product.fromJson,
    );
  }

  Future<Product> getProduct(String id) async {
    final response = await _client.get('/api/products/$id');
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _client.post('/api/products', data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> data) async {
    final response = await _client.put('/api/products/$id', data: data);
    return Product.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    await _client.delete('/api/products/$id');
  }

  Future<List<Product>> getAllForSync({
    required String organizationId,
    String? updatedSince,
    int page = 1,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': 500,
      'page': page,
    };
    if (updatedSince != null) {
      queryParams['updatedSince'] = updatedSince;
    }
    final response = await _client.get('/api/products',
        queryParameters: queryParams);
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>?)
            ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
}