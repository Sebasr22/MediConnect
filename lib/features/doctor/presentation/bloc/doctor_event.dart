part of 'doctor_bloc.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class GetAppointmentsRequested extends DoctorEvent {
  final int doctorId;

  const GetAppointmentsRequested(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}

class CreateAppointmentRequested extends DoctorEvent {
  final int doctorId;
  final String patientName;
  final DateTime date;

  const CreateAppointmentRequested({
    required this.doctorId,
    required this.patientName,
    required this.date,
  });

  @override
  List<Object> get props => [doctorId, patientName, date];
}

class FilterAppointmentsByDateRequested extends DoctorEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterAppointmentsByDateRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}