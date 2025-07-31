import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/appointment_entity.dart';
import '../repositories/doctor_repository.dart';

class CreateAppointmentUseCase {
  final DoctorRepository repository;

  CreateAppointmentUseCase(this.repository);

  Future<Either<Failure, Appointment>> call(CreateAppointmentParams params) async {
    return await repository.createAppointment(
      doctorId: params.doctorId,
      patientName: params.patientName,
      date: params.date,
    );
  }
}

class CreateAppointmentParams {
  final int doctorId;
  final String patientName;
  final DateTime date;

  CreateAppointmentParams({
    required this.doctorId,
    required this.patientName,
    required this.date,
  });
}