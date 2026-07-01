import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'auth/token_storage.dart';
import 'providers/data_providers.dart';
import 'screens/login/login_screen.dart';
import 'screens/main_shell.dart';

final _demoModeProvider = StateProvider<bool>((ref) => false);

void appMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: InvenSyncApp()));
}

class InvenSyncApp extends ConsumerStatefulWidget {
  const InvenSyncApp({super.key});

  @override
  ConsumerState<InvenSyncApp> createState() => _InvenSyncAppState();
}

class _InvenSyncAppState extends ConsumerState<InvenSyncApp> {
  bool _isInitialized = false;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getToken();
    if (token != null) {
      await ref.read(authStateProvider.notifier).restoreSession();
    }
    setState(() {
      _hasSession = token != null;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'InvenSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _hasSession ? const MainShell() : const _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends ConsumerStatefulWidget {
  const _AuthWrapper();

  @override
  ConsumerState<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<_AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull?.user;

    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return LoginScreen(
      onLoginSuccess: () {},
      on2FaRequired: (token) {},
      onStartDemo: () async {
        await ref.read(authStateProvider.notifier).startDemo();
        ref.read(_demoModeProvider.notifier).state = true;
      },
    );
  }
}