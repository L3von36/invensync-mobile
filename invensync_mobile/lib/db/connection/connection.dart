import 'package:drift/drift.dart';
import 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart' as impl;

/// Opens a database connection appropriate for the current platform.
/// On native (Android/iOS): uses SQLite via NativeDatabase.
/// On web: uses sql.js via WebDatabase (IndexedDB-backed).
QueryExecutor openConnection() => impl.openConnection();