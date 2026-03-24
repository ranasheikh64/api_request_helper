import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Future<String?> Function()? getToken;
  final Future<void> Function()? onRefreshToken;
  final Dio dio;

  AuthInterceptor(this.dio, {this.getToken, this.onRefreshToken});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (getToken != null) {
      final token = await getToken!();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && onRefreshToken != null) {
      try {
        await onRefreshToken!();
        // Retry the request after token refresh
        final options = err.requestOptions;
        if (getToken != null) {
          final newToken = await getToken!();
          if (newToken != null) {
            options.headers['Authorization'] = 'Bearer $newToken';
          }
        }
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        return super.onError(err, handler);
      }
    }
    return super.onError(err, handler);
  }
}
