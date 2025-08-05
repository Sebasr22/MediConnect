import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      final result = await repository.logout();
      
      return result.fold(
        (failure) => Left(failure),
        (_) async {
          await _resetBLoCs();
          return const Right(null);
        },
      );
    } catch (e) {
      return const Left(CacheFailure('Error al cerrar sesión'));
    }
  }

  Future<void> _resetBLoCs() async {
    try {
    } catch (e) {
      // Ignore BLoC reset errors
    }
  }
}