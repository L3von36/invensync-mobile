class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int syncIntervalSeconds = 30;
  static const int heartbeatIntervalSeconds = 30;
  static const int heartbeatTimeoutSeconds = 5;

  static const int bootstrapPageSize = 500;
  static const int maxOutboxRetries = 5;

  static const List<Duration> outboxBackoff = [
    Duration(seconds: 2),
    Duration(seconds: 8),
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 10),
  ];

  static const String defaultCurrency = 'ETB';
}