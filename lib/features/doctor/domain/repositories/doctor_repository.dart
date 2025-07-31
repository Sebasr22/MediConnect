import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/appointment_entity.dart';

abstract class DoctorRepository {
  Future<Either<Failure, List<Appointment>>> getDoctorAppointments(int doctorId);
  
  Future<Either<Failure, Appointment>> createAppointment({
    required int doctorId,
    required String patientName,
    required DateTime date,
  });
  
  Future<Either<Failure, List<Appointment>>> filterAppointmentsByDateRange({
    required int doctorId,
    required DateTime startDate,
    required DateTime endDate,
  });
}