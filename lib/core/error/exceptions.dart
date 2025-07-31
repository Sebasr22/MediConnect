class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class ConnectionException implements Exception {
  final String message;
  const ConnectionException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class InvalidCredentialsException implements Exception {
  final String message;
  const InvalidCredentialsException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(this.message);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}