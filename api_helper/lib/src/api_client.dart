import 'package:dio/dio.dart';
import 'models/api_request_options.dart';
import 'models/api_response.dart';
import 'services/cache_service.dart';
import 'services/logging_service.dart';
import 'interceptors/logger_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'isolate_helper.dart';

class ApiClient {
  late Dio _dio;
  final CacheService _cacheService = CacheService();
  final LoggingService _loggingService = LoggingService();
  final String baseUrl;
  Dio get dio => _dio;

  ApiClient({
    required this.baseUrl,
    Future<String?> Function()? getToken,
    Future<void> Function()? onRefreshToken,
    List<Interceptor>? additionalInterceptors,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(LoggerInterceptor(_loggingService));
    _dio.interceptors.add(
      AuthInterceptor(_dio, getToken: getToken, onRefreshToken: onRefreshToken),
    );
    if (additionalInterceptors != null) {
      _dio.interceptors.addAll(additionalInterceptors);
    }
  }

  Future<void> init() async {
    await _cacheService.init();
    _loggingService.logInfo("ApiClient initialized with baseUrl: $baseUrl");
  }

  void manualLog(String message) {
    _loggingService.manualLog(message);
  }

  Future<ApiResponse<T>> request<T>(
    String path, {
    String method = 'GET',
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
    Function(ApiResponse<T>)? onUpdate,
  }) async {
    final opts = options ?? ApiRequestOptions();
    final cacheKey = "${method}_${path}_${opts.queryParameters.hashCode}";

    // Handle Caching for GET requests
    if (method == 'GET' &&
        opts.saveInLocal &&
        _cacheService.hasData(cacheKey)) {
      final cachedData = _cacheService.getData(cacheKey);
      if (cachedData != null) {
        _loggingService.logResponse(
          url: "$baseUrl$path",
          statusCode: 200,
          body: cachedData,
          isFromCache: true,
        );
        _fetchAndCacheInBackground(
          path,
          method,
          opts,
          cacheKey,
          fromJson,
          onUpdate,
        );
        return ApiResponse(
          data: fromJson != null && cachedData is Map<String, dynamic>
              ? fromJson(cachedData)
              : cachedData as T?,
          isFromCache: true,
          statusCode: 200,
        );
      }
    }

    return await _makeRequest(path, method, opts, cacheKey, fromJson);
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String path,
    String method,
    ApiRequestOptions opts,
    String cacheKey,
    T Function(Map<String, dynamic>)? fromJson,
  ) async {
    try {
      Response response;
      Future<Response> requestTask() async {
        return await _dio.request(
          path,
          data: opts.data,
          queryParameters: opts.queryParameters,
          options: Options(
            method: method,
            headers: opts.headers,
            contentType: opts.contentType,
          ),
        );
      }

      if (opts.isIsolate) {
        _loggingService.logInfo("Running request for $path in Isolate");
        response = await IsolateHelper.runInIsolate((_) => requestTask(), null);
      } else {
        response = await requestTask();
      }

      if (opts.saveInLocal && response.data != null) {
        await _cacheService.saveData(cacheKey, response.data);
      }

      return ApiResponse(
        data: fromJson != null && response.data is Map<String, dynamic>
            ? fromJson(response.data)
            : response.data as T?,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      _loggingService.logError(
        url: "$baseUrl$path",
        statusCode: null,
        error: e.toString(),
      );
      return ApiResponse(message: e.toString());
    }
  }

  void _fetchAndCacheInBackground<T>(
    String path,
    String method,
    ApiRequestOptions opts,
    String cacheKey,
    T Function(Map<String, dynamic>)? fromJson,
    Function(ApiResponse<T>)? onUpdate,
  ) {
    // Fire and forget background fetch
    _makeRequest(path, method, opts, cacheKey, fromJson).then((response) {
      _loggingService.logInfo("Background fetch completed for $path");
      if (onUpdate != null) {
        onUpdate(response);
      }
    });
  }

  // Helper methods for specific verbs
  Future<ApiResponse<T>> get<T>(
    String path, {
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
    Function(ApiResponse<T>)? onUpdate,
  }) => request(
    path,
    method: 'GET',
    options: options,
    fromJson: fromJson,
    onUpdate: onUpdate,
  );

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final opts = options ?? ApiRequestOptions();
    opts.data = data;
    return request(path, method: 'POST', options: opts, fromJson: fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final opts = options ?? ApiRequestOptions();
    opts.data = data;
    return request(path, method: 'PUT', options: opts, fromJson: fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) => request(path, method: 'DELETE', options: options, fromJson: fromJson);

  Future<ApiResponse<T>> multipart<T>(
    String path,
    Map<String, dynamic> data, {
    ApiRequestOptions? options,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final formData = FormData.fromMap(data);
    final opts = options ?? ApiRequestOptions();
    opts.data = formData;
    return request(path, method: 'POST', options: opts, fromJson: fromJson);
  }
}
