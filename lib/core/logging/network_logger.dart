import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class NetworkLogger {
  const NetworkLogger();

  void logRequest({
    required String method,
    required Uri uri,
    required int? requestSize,
  }) {
    print("[HTTP] -> $method $uri (${requestSize ?? 0} bytes)");
    if (!kDebugMode) return;
    developer.log(
      '[HTTP] -> $method $uri (${requestSize ?? 0} bytes)',
      name: 'network',
    );
  }

  void logResponse({
    required String method,
    required Uri uri,
    required int statusCode,
    required Duration duration,
    required dynamic responseSize,
  }) {
    if (!kDebugMode) return;
    print(
      "[HTTP] <- $method $uri [$statusCode] (${duration.inMilliseconds}ms, ${responseSize ?? 0} bytes)",
    );
    developer.log(
      '[HTTP] <- $method $uri [$statusCode] (${duration.inMilliseconds}ms, ${responseSize ?? 0} bytes)',
      name: 'network',
    );
  }

  void logError({
    required String method,
    required Uri uri,
    required Duration duration,
    required Object error,
  }) {
    if (!kDebugMode) return;
    print("[HTTP] !! $method $uri (${duration.inMilliseconds}ms) $error");
    developer.log(
      '[HTTP] !! $method $uri (${duration.inMilliseconds}ms) $error',
      name: 'network',
    );
  }
}
