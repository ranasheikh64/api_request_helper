import 'package:dio/dio.dart';
import '../services/logging_service.dart';

class LoggerInterceptor extends Interceptor {
  final LoggingService _loggingService;

  LoggerInterceptor(this._loggingService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _loggingService.logInfo(
      'REQUEST[${options.method}] => PATH: ${options.path}',
    );
    _loggingService.logDebug('Headers: ${options.headers}');
    _loggingService.logDebug('Data: ${options.data}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _loggingService.logInfo(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    _loggingService.logDebug('Data: ${response.data}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _loggingService.logError(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      err.error,
      err.stackTrace,
    );
    return super.onError(err, handler);
  }
}
