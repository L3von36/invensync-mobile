import 'package:shared_preferences/shared_preferences.dart';

/// Token storage using SharedPreferences.
/// TODO: Swap back to flutter_secure_storage for production
/// (requires NDK on Android, keychain on iOS).
class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _orgIdKey = 'organization_id';
  static const _orgNameKey = 'organization_name';
  static const _currencyKey = 'currency';
  static const _bootstrapDoneKey = 'bootstrap_done';
  static const _shopIdKey = 'current_shop_id';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  Future<String?> getOrganizationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_orgIdKey);
  }

  Future<void> saveOrganizationId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orgIdKey, id);
  }

  Future<String?> getOrganizationName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_orgNameKey);
  }

  Future<void> saveOrganizationName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orgNameKey, name);
  }

  Future<String?> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey);
  }

  Future<void> saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency);
  }

  Future<bool> isBootstrapped() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bootstrapDoneKey) ?? false;
  }

  Future<void> setBootstrapped(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bootstrapDoneKey, done);
  }

  Future<String?> getCurrentShopId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_shopIdKey);
  }

  Future<void> setCurrentShopId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shopIdKey, id);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_orgIdKey);
    await prefs.remove(_orgNameKey);
    await prefs.remove(_currencyKey);
    await prefs.remove(_bootstrapDoneKey);
    await prefs.remove(_shopIdKey);
  }
}