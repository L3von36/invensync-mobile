import '../api/api_client.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../models/shop.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verify2Fa({
    required String token,
    required String code,
  }) async {
    final response = await _client.post(
      '/api/auth/login/2fa',
      data: {'token': token, 'code': code},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String organizationName,
    String? businessType,
  }) async {
    final response = await _client.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'organizationName': organizationName,
      if (businessType != null) 'businessType': businessType,
    });
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<User> getMe() async {
    final response = await _client.get('/api/auth/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.post('/api/auth/logout');
  }

  Future<List<Organization>> getOrganizations() async {
    final response = await _client.get('/api/auth/me');
    final data = response.data as Map<String, dynamic>;
    return (data['organizations'] as List<dynamic>?)
            ?.map((e) => Organization.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  Future<List<Shop>> getShops() async {
    final response = await _client.get('/api/shops');
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>?)
            ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }
}