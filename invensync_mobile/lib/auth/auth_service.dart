import 'package:logger/logger.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../auth/token_storage.dart';

class AuthService {
  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  final Logger _logger = Logger();

  AuthService(this._authApi, this._tokenStorage);

  User? _currentUser;
  Organization? _currentOrg;

  User? get currentUser => _currentUser;
  Organization? get currentOrg => _currentOrg;
  bool get isAuthenticated => _currentUser != null;

  Future<LoginResult> login(String email, String password) async {
    try {
      final result = await _authApi.login(email: email, password: password);

      if (result.containsKey('requiresTwoFactor')) {
        return LoginResult.requiresTwoFactor(
            token: result['twoFactorToken'] as String);
      }

      final token = result['token'] as String;
      final user = User.fromJson(result['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(token);
      _currentUser = user;
      await _tokenStorage.saveUserId(user.id);

      if (result['organizations'] != null) {
        final orgs = (result['organizations'] as List<dynamic>)
            .map((e) => Organization.fromJson(e as Map<String, dynamic>))
            .toList();
        if (orgs.isNotEmpty) {
          await setOrganization(orgs.first);
        }
      }

      return LoginResult.success(user: user);
    } catch (e) {
      _logger.e('Login failed: $e');
      return LoginResult.error(message: e.toString());
    }
  }

  Future<LoginResult> verify2Fa(String token, String code) async {
    try {
      final result = await _authApi.verify2Fa(token: token, code: code);
      final jwt = result['token'] as String;
      final user = User.fromJson(result['user'] as Map<String, dynamic>);

      await _tokenStorage.saveToken(jwt);
      _currentUser = user;
      await _tokenStorage.saveUserId(user.id);

      return LoginResult.success(user: user);
    } catch (e) {
      return LoginResult.error(message: 'Invalid 2FA code');
    }
  }

  Future<void> setOrganization(Organization org) async {
    _currentOrg = org;
    await _tokenStorage.saveOrganizationId(org.id);
    await _tokenStorage.saveOrganizationName(org.name);
    if (org.currency != null) {
      await _tokenStorage.saveCurrency(org.currency!);
    }
  }

  Future<bool> restoreSession() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) return false;

      final user = await _authApi.getMe();
      _currentUser = user;
      await _tokenStorage.saveUserId(user.id);
      return true;
    } catch (e) {
      _logger.w('Session restore failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {}
    await _tokenStorage.clearAll();
    _currentUser = null;
    _currentOrg = null;
  }
}

class LoginResult {
  final bool success;
  final bool requiresTwoFactor;
  final User? user;
  final String? token;
  final String? message;

  const LoginResult._({
    this.success = false,
    this.requiresTwoFactor = false,
    this.user,
    this.token,
    this.message,
  });

  factory LoginResult.success({required User user}) =>
      LoginResult._(success: true, user: user);

  factory LoginResult.requiresTwoFactor({required String token}) =>
      LoginResult._(requiresTwoFactor: true, token: token);

  factory LoginResult.error({required String message}) =>
      LoginResult._(message: message);
}