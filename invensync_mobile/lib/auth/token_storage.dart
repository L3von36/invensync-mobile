import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _orgIdKey = 'organization_id';
  static const _orgNameKey = 'organization_name';
  static const _currencyKey = 'currency';
  static const _bootstrapDoneKey = 'bootstrap_done';
  static const _shopIdKey = 'current_shop_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _userIdKey, value: id);

  Future<String?> getOrganizationId() => _storage.read(key: _orgIdKey);

  Future<void> saveOrganizationId(String id) =>
      _storage.write(key: _orgIdKey, value: id);

  Future<String?> getOrganizationName() => _storage.read(key: _orgNameKey);

  Future<void> saveOrganizationName(String name) =>
      _storage.write(key: _orgNameKey, value: name);

  Future<String?> getCurrency() => _storage.read(key: _currencyKey);

  Future<void> saveCurrency(String currency) =>
      _storage.write(key: _currencyKey, value: currency);

  Future<bool> isBootstrapped() async {
    final val = await _storage.read(key: _bootstrapDoneKey);
    return val == 'true';
  }

  Future<void> setBootstrapped(bool done) =>
      _storage.write(key: _bootstrapDoneKey, value: done.toString());

  Future<String?> getCurrentShopId() => _storage.read(key: _shopIdKey);

  Future<void> setCurrentShopId(String id) =>
      _storage.write(key: _shopIdKey, value: id);

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}