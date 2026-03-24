import 'package:dio/dio.dart';
import '../services/logging_service.dart';

class LoggerInterceptor extends Interceptor {
  final LoggingService _loggingService;

  LoggerInterceptor(this._loggingService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _loggingService.logRequest(
      url: "${options.baseUrl}${options.path}",
      method: options.method,
      headers: options.headers,
      body: options.data,
    );
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _loggingService.logResponse(
      url: "${response.requestOptions.baseUrl}${response.requestOptions.path}",
      statusCode: response.statusCode,
      body: response.data,
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _loggingService.logError(
      url: "${err.requestOptions.baseUrl}${err.requestOptions.path}",
      statusCode: err.response?.statusCode,
      error: err.message ?? err.error,
      stackTrace: err.stackTrace,
    );
    return super.onError(err, handler);
  }
}
