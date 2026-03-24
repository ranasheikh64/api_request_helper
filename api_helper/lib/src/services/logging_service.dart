import 'package:logger/logger.dart';

class LoggingService {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  void logInfo(String message) {
    _logger.i(message);
  }

  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void logWarning(String message) {
    _logger.w(message);
  }

  void logDebug(String message) {
    _logger.d(message);
  }

  void manualLog(String message) {
    _logger.i("[MANUAL] $message");
  }
}
