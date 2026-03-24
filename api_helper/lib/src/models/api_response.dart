class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool isFromCache;

  ApiResponse({
    this.data,
    this.message,
    this.statusCode,
    this.isFromCache = false,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    bool isFromCache = false,
  }) {
    return ApiResponse(
      data: json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int?,
      isFromCache: isFromCache,
    );
  }
}
