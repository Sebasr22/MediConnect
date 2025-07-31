import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/doctor_entity.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<Doctor>>> getAllDoctors();
  
  Future<Either<Failure, Doctor>> getDoctorById(int doctorId);
}