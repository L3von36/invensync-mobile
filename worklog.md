---
Task ID: 1
Agent: Main Agent
Task: Build Flutter mobile app for InvenSync (offline-first, connects to existing Next.js API)

Work Log:
- Installed Flutter 3.44.4 SDK
- Created Flutter project at /home/z/my-project/invensync_mobile
- Set up pubspec.yaml with: flutter_riverpod, dio, drift, sqlite3_flutter_libs, connectivity_plus, go_router, flutter_secure_storage
- Built 15+ data models matching API response shapes (Product, Sale, Customer, etc.)
- Built Dio-based API client with auth interceptor and offline error detection
- Built 5 API modules (Auth, Products, Sales, Customers, Sync/Dashboard/Inventory)
- Built Drift database with 12 tables (Products, Customers, Suppliers, Sales, SaleItems, StockMovements, Debts, Shops, Expenses, ProductTypes, Outbox, SyncMeta)
- Built SyncEngine with bootstrap hydration, delta sync, outbox push, 5 conflict strategies
- Built ConnectivityService with platform detection and debounced heartbeat
- Built AuthService with login, 2FA, session restore, org selection
- Built Riverpod providers (auth, sync, connectivity, products, customers, sales)
- Built 5 screens: Dashboard, Products (search/filter), Sales, Inventory (stock alerts), Customers
- Built widgets: OfflineBanner, SyncIndicator
- Built Material 3 theme (light/dark) with InvenSync branding
- Full build_runner code generation for Drift
- Fixed all type conflicts between Drift-generated and API model classes
- flutter analyze: 0 errors, only minor warnings
- Web build fails expectedly (dart:ffi not available) - app targets Android/iOS

Stage Summary:
- Produced: /home/z/my-project/invensync_mobile/ (complete Flutter project)
- 40+ Dart source files, 12 DB tables, full sync engine architecture
- Connects to existing Next.js API at http://10.0.2.2:3000 (configurable via API_BASE_URL env var)
- Ready for `flutter run` on Android/iOS emulator or device