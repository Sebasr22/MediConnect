import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/doctor_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterDoctorUseCase {
  final AuthRepository repository;

  RegisterDoctorUseCase(this.repository);

  Future<Either<Failure, Doctor>> call(RegisterDoctorParams params) async {
    return await repository.registerDoctor(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      specialty: params.specialty,
      rating: params.rating,
    );
  }
}

class RegisterDoctorParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String specialty;
  final double rating;

  RegisterDoctorParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.specialty,
    required this.rating,
  });
}