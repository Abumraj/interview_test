sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  const ApiException({required this.message, this.statusCode, this.cause});

  @override
  String toString() =>
      '$runtimeType(statusCode: $statusCode, message: $message)';
}

class NetworkUnavailableException extends ApiException {
  const NetworkUnavailableException({
    super.message = 'No internet connection',
    super.cause,
  }) : super(statusCode: null);
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException({
    super.message = 'Request timed out',
    super.cause,
  }) : super(statusCode: null);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? details;

  const ValidationException({
    required super.message,
    super.statusCode,
    super.cause,
    this.details,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
    super.cause,
  });
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Forbidden',
    super.statusCode = 403,
    super.cause,
  });
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.statusCode = 404,
    super.cause,
  });
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error',
    super.statusCode,
    super.cause,
  });
}

class UnknownApiException extends ApiException {
  const UnknownApiException({
    super.message = 'Unexpected error',
    super.statusCode,
    super.cause,
  });
}
