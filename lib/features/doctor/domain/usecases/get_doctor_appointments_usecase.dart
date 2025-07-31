import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/appointment_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorAppointmentsUseCase {
  final DoctorRepository repository;

  GetDoctorAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<Appointment>>> call(int doctorId) async {
    return await repository.getDoctorAppointments(doctorId);
  }
}