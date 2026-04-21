import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timed out. Please check your network.',
          statusCode: null,
          errorCode: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection.',
          statusCode: null,
          errorCode: 'NO_INTERNET',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data is Map ? (data['message'] as String? ?? 'Server error') : 'Server error';
        final errorCode = data is Map ? data['code'] as String? : null;
        return ApiException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
        );
      default:
        return ApiException(message: e.message ?? 'Unknown error', errorCode: 'UNKNOWN');
    }
  }

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiException(message: $message, code: $statusCode)';
}

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Attempt silent token refresh
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) {
          await _storage.clearAll();
          handler.next(err);
          return;
        }
        final response = await _dio.post(
          '/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;
        await _storage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );
        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _dio.fetch(opts);
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        await _storage.clearAll();
      }
    }
    handler.next(err);
  }
}

class ApiClient {
  static const String _defaultBaseUrl = 'https://api.hodon.app/v1';

  late final Dio _dio;
  final SecureStorageService _storage;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': '1.0.0',
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? mapper,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return mapper != null ? mapper(response.data) : response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? mapper,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return mapper != null ? mapper(response.data) : response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? mapper,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return mapper != null ? mapper(response.data) : response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? extraData,
    T Function(dynamic)? mapper,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?extraData,
      });
      final response = await _dio.post(path, data: formData);
      return mapper != null ? mapper(response.data) : response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

