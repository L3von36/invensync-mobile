import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../db/database.dart' hide User;
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../api/products_api.dart';
import '../api/sales_api.dart';
import '../api/customers_api.dart';
import '../api/sync_api.dart';
import '../auth/token_storage.dart';
import '../auth/auth_service.dart';
import '../sync/sync_engine.dart';
import '../sync/connectivity_service.dart';
import '../models/user.dart' as models;
import '../models/organization.dart' as models;
import '../utils/demo_seeder.dart';

// ============================================
// CORE SINGLETONS
// ============================================

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return ApiClient(tokenStorage);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============================================
// AUTH
// ============================================

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return AuthService(AuthApi(apiClient), tokenStorage);
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService, ref);
});

class AuthState {
  final models.User? user;
  final models.Organization? organization;
  final bool isLoading;
  final bool isBootstrapped;

  const AuthState({
    this.user, this.organization,
    this.isLoading = false, this.isBootstrapped = false,
  });

  AuthState copyWith({
    models.User? user, models.Organization? organization,
    bool? isLoading, bool? isBootstrapped,
  }) {
    return AuthState(
      user: user ?? this.user,
      organization: organization ?? this.organization,
      isLoading: isLoading ?? this.isLoading,
      isBootstrapped: isBootstrapped ?? this.isBootstrapped,
    );
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final AuthService _authService;
  final Ref _ref;

  AuthNotifier(this._authService, this._ref)
      : super(const AsyncValue.data(AuthState()));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.login(email, password);
      if (result.requiresTwoFactor) {
        state = AsyncValue.data(AuthState(isLoading: false));
        return;
      }
      if (result.success && result.user != null) {
        state = AsyncValue.data(AuthState(
          user: result.user,
          organization: _authService.currentOrg,
        ));
        await _bootstrapIfNeeded();
      } else {
        state = AsyncValue.error(
            Exception(result.message ?? 'Login failed'), StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verify2Fa(String token, String code) async {
    state = const AsyncValue.loading();
    try {
      final result = await _authService.verify2Fa(token, code);
      if (result.success && result.user != null) {
        state = AsyncValue.data(AuthState(user: result.user));
        await _bootstrapIfNeeded();
      } else {
        state = AsyncValue.error(
            Exception(result.message ?? '2FA failed'), StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startDemo() async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseProvider);
      final tokenStorage = _ref.read(tokenStorageProvider);
      final seeder = DemoSeeder(db, tokenStorage);
      await seeder.seed();
      state = AsyncValue.data(AuthState(
        user: models.User(
          id: 'demo-user-001',
          email: 'demo@invensync.com',
          name: 'Demo User',
          role: 'admin',
        ),
        organization: models.Organization(
          id: 'demo-org-001',
          name: 'InvenSync Demo',
          slug: 'invensync-demo',
          role: 'admin',
          currency: 'ETB',
        ),
        isBootstrapped: true,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> restoreSession() async {
    state = const AsyncValue.data(AuthState(isLoading: true));
    try {
      final restored = await _authService.restoreSession();
      if (restored) {
        state = AsyncValue.data(AuthState(
          user: _authService.currentUser,
          organization: _authService.currentOrg,
        ));
      } else {
        state = const AsyncValue.data(AuthState());
      }
    } catch (e, st) {
      state = AsyncValue.data(const AuthState());
    }
  }

  Future<void> setOrganization(models.Organization org) async {
    await _authService.setOrganization(org);
    state = AsyncValue.data(AuthState(
      user: _authService.currentUser,
      organization: org,
    ));
    await _bootstrapIfNeeded();
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(AuthState());
  }

  Future<void> _bootstrapIfNeeded() async {
    final tokenStorage = _ref.read(tokenStorageProvider);
    final db = _ref.read(databaseProvider);
    final syncEngine = _ref.read(syncEngineProvider);
    final orgId = _authService.currentOrg?.id;

    if (orgId == null) return;

    final alreadyBootstrapped = await tokenStorage.isBootstrapped();
    if (alreadyBootstrapped) return;

    state = AsyncValue.data(state.value?.copyWith(isLoading: true) ??
        const AuthState(isLoading: true));

    try {
      await syncEngine.bootstrap(orgId);
      await tokenStorage.setBootstrapped(true);
      state = AsyncValue.data(AuthState(
        user: _authService.currentUser,
        organization: _authService.currentOrg,
        isBootstrapped: true,
      ));
    } catch (e) {
      Logger().e('Bootstrap failed', error: e);
      state = AsyncValue.data(state.value?.copyWith(isLoading: false) ??
          const AuthState());
    }
  }
}

// ============================================
// SYNC ENGINE
// ============================================

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final db = ref.read(databaseProvider);
  final apiClient = ref.read(apiClientProvider);
  return SyncEngine(db, apiClient);
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final engine = ref.watch(syncEngineProvider);
  return engine.statusStream;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.isOnlineStream;
});

// ============================================
// DATA PROVIDERS
// ============================================

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(databaseProvider);
  final authState = ref.watch(authStateProvider);
  final orgId = authState.value?.organization?.id;

  if (orgId == null || orgId.isEmpty) return [];
  return db.getActiveProducts(orgId);
});

final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final db = ref.read(databaseProvider);
  final authState = ref.watch(authStateProvider);
  final orgId = authState.value?.organization?.id;

  if (orgId == null || orgId.isEmpty) return [];
  return db.getAllCustomers(orgId);
});

final recentSalesProvider = FutureProvider<List<Sale>>((ref) async {
  final db = ref.read(databaseProvider);
  final authState = ref.watch(authStateProvider);
  final orgId = authState.value?.organization?.id;

  if (orgId == null || orgId.isEmpty) return [];
  return db.getRecentSales(orgId, limit: 20);
});

final pendingOutboxCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getPendingOutboxCount();
});

// (imports moved to top of file)