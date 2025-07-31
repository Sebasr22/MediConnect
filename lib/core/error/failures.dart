import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message]);
  
  final String? message;
  
  @override
  List<Object?> get props => [message];
}

// Errores generales
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([super.message]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message]);
}

// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure([super.message]);
}