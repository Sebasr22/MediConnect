import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/patient_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterPatientUseCase {
  final AuthRepository repository;

  RegisterPatientUseCase(this.repository);

  Future<Either<Failure, Patient>> call(RegisterPatientParams params) async {
    return await repository.registerPatient(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      birthdate: params.birthdate,
    );
  }
}

class RegisterPatientParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final DateTime birthdate;

  RegisterPatientParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.birthdate,
  });
}