class ApiRequestOptions {
  final bool isIsolate;
  final bool saveInLocal;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  dynamic data;
  final String? contentType;

  ApiRequestOptions({
    this.isIsolate = false,
    this.saveInLocal = false,
    this.queryParameters,
    this.headers,
    this.data,
    this.contentType,
  });
}
