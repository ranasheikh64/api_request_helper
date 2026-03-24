import 'package:flutter/foundation.dart';

class IsolateHelper {
  /// Runs a function in an isolate using compute.
  /// Useful for parsing large JSON data without blocking the UI thread.
  static Future<T> runInIsolate<T, P>(
    ComputeCallback<P, T> callback,
    P message,
  ) async {
    return await compute(callback, message);
  }
}
