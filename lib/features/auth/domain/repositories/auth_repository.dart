import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/doctor_entity.dart';
import '../entities/patient_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, Doctor>> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required double rating,
  });

  Future<Either<Failure, Patient>> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    required DateTime birthdate,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, bool>> isAuthenticated();
}