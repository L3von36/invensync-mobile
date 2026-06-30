import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../auth/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient(this._tokenStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(_tokenStorage),
      OfflineErrorInterceptor(),
      LogInterceptor(requestBody: false, responseBody: false),
    ]);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(path, queryParameters: queryParameters);
  }

  Dio get dio => _dio;
}

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _tokenStorage.clearAll();
    }
    handler.next(err);
  }
}

class OfflineErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      handler.next(DioException(
        requestOptions: err.requestOptions,
        error: 'OFFLINE',
        type: err.type,
        message: 'No internet connection',
      ));
    } else {
      handler.next(err);
    }
  }
}