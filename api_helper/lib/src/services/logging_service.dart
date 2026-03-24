import 'package:logger/logger.dart';

class LoggingService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void logRequest({
    required String url,
    required String method,
    dynamic headers,
    dynamic body,
  }) {
    _logger.i("""
🚀 [API REQUEST]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL:    $url
METHOD: $method
HEADERS: $headers
BODY:    $body
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""");
  }

  void logResponse({
    required String url,
    required int? statusCode,
    required dynamic body,
    bool isFromCache = false,
  }) {
    final cacheTag = isFromCache ? " [💾 CACHED]" : "";
    _logger.i("""
✅ [API RESPONSE]$cacheTag
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL:    $url
STATUS: $statusCode
BODY:    $body
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""");
  }

  void logError({
    required String url,
    required int? statusCode,
    required dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e("""
❌ [API ERROR]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
URL:    $url
STATUS: $statusCode
ERROR:  $error
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
""", error: error, stackTrace: stackTrace);
  }

  void manualLog(String message) {
    _logger.i("📝 [MANUAL] $message");
  }

  void logInfo(String message) => _logger.i(message);
  void logWarning(String message) => _logger.w(message);
  void logDebug(String message) => _logger.d(message);
}
