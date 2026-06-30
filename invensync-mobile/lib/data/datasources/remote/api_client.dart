import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? 'https://your-invensync-instance.com',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        )),
        _secureStorage = const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Token helpers
  // ---------------------------------------------------------------------------

  /// Read the persisted auth token (or `null` if none exists).
  Future<String?> getToken() => _secureStorage.read(key: 'auth_token');

  /// Persist a new auth token.
  Future<void> setToken(String token) =>
      _secureStorage.write(key: 'auth_token', value: token);

  /// Remove the persisted auth token.
  Future<void> clearToken() => _secureStorage.delete(key: 'auth_token');

  // ---------------------------------------------------------------------------
  // Interceptors
  // ---------------------------------------------------------------------------

  /// Wire up the request / error interceptors.
  ///
  /// Call this once after creating the client (or after switching tokens).
  void setupAuthInterceptor() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired – let the auth provider react.
          clearToken();
        }
        handler.next(error);
      },
    ));
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await _dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verify2fa(String tempToken, String code) async {
    final resp = await _dio.post(
      '/api/auth/login/2fa',
      data: {'tempToken': tempToken, 'code': code},
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/auth/register', data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final resp = await _dio.get('/api/auth/me');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {}
    await clearToken();
  }

  // ==================== PRODUCTS ====================

  Future<List<dynamic>> getProducts({
    String? orgId,
    String? shopId,
    String? search,
    int page = 1,
    int limit = 50,
    bool? isActive,
  }) async {
    final resp = await _dio.get(
      '/api/products',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'search': search,
        'page': page,
        'limit': limit,
        'isActive': isActive,
      }),
    );
    return _extractList(resp.data, ['data', 'products']);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/products', data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.put('/api/products/$id', data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<void> deleteProduct(String id) async {
    await _dio.delete('/api/products/$id');
  }

  // ==================== PRODUCT TYPES (Categories) ====================

  Future<List<dynamic>> getProductTypes({String? orgId}) async {
    final resp = await _dio.get(
      '/api/product-types',
      queryParameters: _removeNulls({'organizationId': orgId}),
    );
    return _extractList(resp.data, ['data', 'productTypes']);
  }

  // ==================== CUSTOMERS ====================

  Future<List<dynamic>> getCustomers({
    String? orgId,
    String? shopId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/customers',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'search': search,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'customers']);
  }

  Future<Map<String, dynamic>> createCustomer(
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.post('/api/customers', data: data);
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> data,
  ) async {
    final resp = await _dio.put('/api/customers/$id', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ==================== SUPPLIERS ====================

  Future<List<dynamic>> getSuppliers({
    String? orgId,
    String? shopId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/suppliers',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'search': search,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'suppliers']);
  }

  // ==================== SALES ====================

  Future<List<dynamic>> getSales({
    String? orgId,
    String? shopId,
    String? status,
    String? fromDate,
    String? toDate,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/sales',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'status': status,
        'fromDate': fromDate,
        'toDate': toDate,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'sales']);
  }

  Future<Map<String, dynamic>> createSale(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/sales', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ==================== INVENTORY ====================

  Future<List<dynamic>> getStockMovements({
    String? orgId,
    String? shopId,
    String? productId,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/inventory',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'productId': productId,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'movements']);
  }

  Future<Map<String, dynamic>> adjustStock(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/inventory', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ==================== DEBTS ====================

  Future<List<dynamic>> getDebts({
    String? orgId,
    String? shopId,
    String? type,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/debts',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'type': type,
        'status': status,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'debts']);
  }

  Future<Map<String, dynamic>> createDebt(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/debts', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ==================== EXPENSES ====================

  Future<List<dynamic>> getExpenses({
    String? orgId,
    String? shopId,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final resp = await _dio.get(
      '/api/expenses',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
        'category': category,
        'page': page,
        'limit': limit,
      }),
    );
    return _extractList(resp.data, ['data', 'expenses']);
  }

  Future<Map<String, dynamic>> createExpense(Map<String, dynamic> data) async {
    final resp = await _dio.post('/api/expenses', data: data);
    return resp.data as Map<String, dynamic>;
  }

  // ==================== SHOPS ====================

  Future<List<dynamic>> getShops({String? orgId}) async {
    final resp = await _dio.get(
      '/api/shops',
      queryParameters: _removeNulls({'organizationId': orgId}),
    );
    return _extractList(resp.data, ['data', 'shops']);
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> getDashboard({
    String? orgId,
    String? shopId,
  }) async {
    final resp = await _dio.get(
      '/api/dashboard',
      queryParameters: _removeNulls({
        'organizationId': orgId,
        'shopId': shopId,
      }),
    );
    return resp.data as Map<String, dynamic>;
  }

  // ==================== DELTA SYNC ====================

  Future<Map<String, dynamic>> getDelta({
    required String entity,
    required String updatedSince,
  }) async {
    final resp = await _dio.get(
      '/api/$entity',
      queryParameters: {'updatedSince': updatedSince},
    );
    final data = resp.data;
    if (data is Map) return data as Map<String, dynamic>;
    return {'data': data, 'hasMore': false};
  }

  // ==================== PING ====================

  /// Returns `true` when the server is reachable.
  Future<bool> ping() async {
    try {
      final resp = await _dio.head('/api/ping');
      return resp.statusCode == 200 || resp.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ==================== BOOTSTRAP ====================

  /// Fetch **all** entity data in parallel for initial sync.
  Future<Map<String, List<dynamic>>> bootstrapData({
    required String orgId,
    String? shopId,
  }) async {
    final entities = {
      'products': getProducts(orgId: orgId, shopId: shopId, limit: 500),
      'categories': getProductTypes(orgId: orgId),
      'customers': getCustomers(orgId: orgId, shopId: shopId, limit: 500),
      'suppliers': getSuppliers(orgId: orgId, shopId: shopId, limit: 500),
      'sales': getSales(orgId: orgId, shopId: shopId, limit: 500),
      'stockMovements':
          getStockMovements(orgId: orgId, shopId: shopId, limit: 500),
      'debts': getDebts(orgId: orgId, shopId: shopId, limit: 500),
      'expenses': getExpenses(orgId: orgId, shopId: shopId, limit: 500),
      'shops': getShops(orgId: orgId),
    };

    final responses = await Future.wait(
      entities.entries
          .map((e) => e.value.then((r) => MapEntry(e.key, r))),
    );

    return Map.fromEntries(responses);
  }

  // ---------------------------------------------------------------------------
  // Outbox push helper
  // ---------------------------------------------------------------------------

  /// Push a single outbox item to the server.
  Future<Response> pushOutboxItem({
    required String method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    switch (method.toUpperCase()) {
      case 'POST':
        return await _dio.post(path, data: data);
      case 'PUT':
        return await _dio.put(path, data: data);
      case 'DELETE':
        return await _dio.delete(path);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Strip null values from a map so Dio doesn't append `?key=` for nulls.
  Map<String, dynamic> _removeNulls(Map<String, dynamic> params) {
    return Map.fromEntries(
      params.entries.where((e) => e.value != null),
    );
  }

  /// Normalise the API response into a [List<dynamic>].
  ///
  /// Some endpoints return the list directly, others wrap it in an envelope
  /// (e.g. `{"data": [...]}` or `{"products": [...]}`).
  List<dynamic> _extractList(
    dynamic data,
    List<String> keys, {
  }) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        if (data[key] is List) return data[key] as List<dynamic>;
      }
    }
    return [];
  }
}