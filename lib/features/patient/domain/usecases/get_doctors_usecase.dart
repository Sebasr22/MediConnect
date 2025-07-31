import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/doctor_entity.dart';
import '../repositories/patient_repository.dart';

class GetDoctorsUseCase {
  final PatientRepository repository;

  GetDoctorsUseCase(this.repository);

  Future<Either<Failure, List<Doctor>>> call() async {
    return await repository.getAllDoctors();
  }
}