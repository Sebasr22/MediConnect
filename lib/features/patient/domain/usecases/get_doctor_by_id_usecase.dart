import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/doctor_entity.dart';
import '../repositories/patient_repository.dart';

class GetDoctorByIdUseCase {
  final PatientRepository repository;

  GetDoctorByIdUseCase(this.repository);

  Future<Either<Failure, Doctor>> call(int doctorId) async {
    return await repository.getDoctorById(doctorId);
  }
}