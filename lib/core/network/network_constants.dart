class NetworkConstants {
  static const String postmanBaseUrlVariableName = 'lwc_dev_baseUrl';

  static String resolveBaseUrl({required String configuredBaseUrl}) {
    final trimmed = configuredBaseUrl.trim();
    if (trimmed.isEmpty) {
      throw StateError(
        'Base URL is not configured. Provide a value for ${NetworkConstants.postmanBaseUrlVariableName}.',
      );
    }
    return trimmed;
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
