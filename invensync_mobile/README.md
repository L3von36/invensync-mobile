# InvenSync Mobile

Offline-first inventory & sales ERP mobile app — connects to your existing InvenSync Next.js API.

## Quick Start

### Prerequisites
- Flutter 3.44+ ([install](https://docs.flutter.dev/get-started/install))
- Android Studio (for Android) or Xcode (for iOS)
- Your InvenSync web app running (the API server)

### 1. Clone & Install

```bash
git clone https://github.com/YOUR_USER/invensync_mobile.git
cd invensync_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 2. Configure API URL

Edit `lib/config/app_config.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',  // Android emulator → host
);
```

Or pass it at build time:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:3000
```

### 3. Run

```bash
# Android
flutter run

# iOS
flutter run -d iPhone

# Debug APK
flutter build apk --debug
```

## Architecture

```
┌─────────────────────────────────────────┐
│  Flutter Mobile App                     │
│                                         │
│  UI (Riverpod + Material 3)             │
│  ├── Dashboard, Products, Sales, etc.  │
│  └── OfflineBanner, SyncIndicator      │
│                                         │
│  State: Riverpod Providers             │
│  ├── AuthState, Products, Sales, etc.  │
│  └── Connectivity, SyncStatus          │
│                                         │
│  Sync Engine                            │
│  ├── Bootstrap (full hydration)         │
│  ├── Delta Pull (?updatedSince=)        │
│  ├── Outbox Push (offline mutations)   │
│  └── 5 Conflict Strategies             │
│                                         │
│  Local DB: Drift/SQLite                 │
│  ├── 12 tables (products, sales, etc.) │
│  ├── Outbox table (pending mutations)  │
│  └── SyncMeta (per-entity timestamps)  │
│                                         │
│  API Client: Dio → Next.js Server       │
└─────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────┐
│  InvenSync Web (Next.js)                │
│  - 109 API routes                       │
│  - Prisma + Supabase/SQLite             │
│  - Same API the web app uses            │
└─────────────────────────────────────────┘
```

## Sync Architecture

| Feature | Details |
|---------|---------|
| **Bootstrap** | Full data hydration on login (paginated, 500/page) |
| **Delta Pull** | `GET /api/{entity}?updatedSince=<timestamp>` |
| **Outbox Push** | Offline mutations queued locally, pushed with exponential backoff (2s→8s→30s→2m→10m) |
| **Conflict Resolution** | LWW, server-wins, client-wins, delta-merge (for inventory counts), manual |
| **Connectivity** | Real-time detection via `connectivity_plus` + debouncing |

## Screens

| Screen | Features |
|--------|----------|
| **Dashboard** | Stats cards, quick actions, recent sales, offline banner |
| **Products** | Search, filter (low stock / out of stock / active), product cards |
| **Sales** | Sale list with status badges, payment method, timestamps |
| **Inventory** | Stock value summary, out-of-stock alerts, low-stock alerts, all products |
| **Customers** | Search, customer cards with contact info |

## Project Structure

```
lib/
├── config/          # App config, theme
├── models/          # API response models (15+ files)
├── api/             # API client, endpoint modules
├── db/              # Drift database (12 tables + generated code)
├── sync/            # Sync engine, connectivity
├── auth/            # Auth service, token storage
├── providers/       # Riverpod providers
├── screens/         # UI screens
├── widgets/         # Reusable widgets
└── utils/           # Formatters, validators
```

## Production Notes

- **Token Storage**: Currently uses `shared_preferences`. For production, swap to `flutter_secure_storage` (requires NDK on Android).
- **API URL**: Change `API_BASE_URL` env var or edit `app_config.dart`.
- **ProGuard/R8**: Enable in `android/app/build.gradle.kts` for release shrinking.
- **Signing**: Configure signing keys in `android/app/build.gradle.kts` for Play Store.
- **CI/CD**: GitHub Actions workflows included (`.github/workflows/`) for auto-building APKs on push/tag.

## License

Private — InvenSync