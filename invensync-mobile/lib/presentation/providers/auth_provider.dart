import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';

// ---------------------------------------------------------------------------
// API Client singleton provider
// ---------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  client.setupAuthInterceptor();
  return client;
});

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? token;
  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> organizations;
  final Map<String, dynamic>? currentOrg;
  final List<Map<String, dynamic>> shops;
  final Map<String, dynamic>? currentShop;
  final String? error;
  final bool requires2fa;
  final String? tempToken;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.token,
    this.user,
    this.organizations = const [],
    this.currentOrg,
    this.shops = const [],
    this.currentShop,
    this.error,
    this.requires2fa = false,
    this.tempToken,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? token,
    Map<String, dynamic>? user,
    List<Map<String, dynamic>>? organizations,
    Map<String, dynamic>? currentOrg,
    List<Map<String, dynamic>>? shops,
    Map<String, dynamic>? currentShop,
    String? error,
    bool? requires2fa,
    String? tempToken,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      user: user ?? this.user,
      organizations: organizations ?? this.organizations,
      currentOrg: currentOrg ?? this.currentOrg,
      shops: shops ?? this.shops,
      currentShop: currentShop ?? this.currentShop,
      error: clearError ? null : (error ?? this.error),
      requires2fa: requires2fa ?? this.requires2fa,
      tempToken: tempToken ?? this.tempToken,
    );
  }
}

// ---------------------------------------------------------------------------
// Auth notifier
// ---------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkExistingSession();
  }

  // ------ Session restoration ------

  Future<void> _checkExistingSession() async {
    final token = await _api.getToken();
    if (token == null) return;

    try {
      final me = await _api.getMe();
      final user = me['user'] ?? me;
      final orgs = _toListOfMaps(me['organizations']);
      final org = orgs.isNotEmpty ? orgs.first : null;

      state = state.copyWith(
        token: token,
        user: user as Map<String, dynamic>?,
        organizations: orgs,
        currentOrg: org,
        isAuthenticated: true,
      );

      if (org != null) {
        await _fetchShops(org['id'] as String);
      }
    } catch (_) {
      await _api.clearToken();
    }
  }

  // ------ Login ------

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _api.login(email, password);

      // 2FA gate
      if (result['requires2fa'] == true) {
        state = state.copyWith(
          isLoading: false,
          requires2fa: true,
          tempToken: result['tempToken'] as String?,
          user: result['user'] as Map<String, dynamic>?,
        );
        return;
      }

      final token = result['token'] as String;
      await _api.setToken(token);
      _api.setupAuthInterceptor();

      final user = result['user'] ?? {};
      final orgs = _toListOfMaps(result['organizations']);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        user: user as Map<String, dynamic>?,
        organizations: orgs,
        currentOrg: orgs.isNotEmpty ? orgs.first : null,
      );

      if (orgs.isNotEmpty) {
        await _fetchShops(orgs.first['id'] as String);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ------ 2FA verification ------

  Future<void> verify2fa(String code) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tempToken = state.tempToken!;
      final result = await _api.verify2fa(tempToken, code);

      final token = result['token'] as String;
      await _api.setToken(token);
      _api.setupAuthInterceptor();

      final user = result['user'] ?? {};
      final orgs = _toListOfMaps(result['organizations']);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
        user: user as Map<String, dynamic>?,
        organizations: orgs,
        currentOrg: orgs.isNotEmpty ? orgs.first : null,
        requires2fa: false,
        tempToken: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ------ Shops ------

  Future<void> _fetchShops(String orgId) async {
    try {
      final shopsData = await _api.getShops(orgId: orgId);
      final shops = shopsData
          .map((e) => e as Map<String, dynamic>)
          .toList();
      state = state.copyWith(
        shops: shops,
        currentShop: shops.isNotEmpty ? shops.first : null,
      );
    } catch (_) {}
  }

  // ------ Org / Shop switching ------

  void setCurrentOrg(Map<String, dynamic> org) {
    state = state.copyWith(currentOrg: org);
    _fetchShops(org['id'] as String);
  }

  void setCurrentShop(Map<String, dynamic> shop) {
    state = state.copyWith(currentShop: shop);
  }

  // ------ Logout ------

  Future<void> logout() async {
    await _api.logout();
    state = const AuthState();
  }

  // ------ Convenience getters ------

  String? get currentOrgId => state.currentOrg?['id'] as String?;
  String? get currentShopId => state.currentShop?['id'] as String?;

  // ------ Helpers ------

  static List<Map<String, dynamic>> _toListOfMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthNotifier(api);
});