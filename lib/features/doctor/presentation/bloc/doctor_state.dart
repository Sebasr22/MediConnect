part of 'doctor_bloc.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class CreatingAppointment extends DoctorState {}

class AppointmentsLoaded extends DoctorState {
  final List<Appointment> appointments;
  final List<Appointment> filteredAppointments;

  const AppointmentsLoaded({
    required this.appointments,
    required this.filteredAppointments,
  });

  @override
  List<Object> get props => [appointments, filteredAppointments];

  AppointmentsLoaded copyWith({
    List<Appointment>? appointments,
    List<Appointment>? filteredAppointments,
  }) {
    return AppointmentsLoaded(
      appointments: appointments ?? this.appointments,
      filteredAppointments: filteredAppointments ?? this.filteredAppointments,
    );
  }

  // Helper methods
  List<Appointment> get todayAppointments {
    return filteredAppointments.where((appointment) => appointment.isToday).toList();
  }

  List<Appointment> get upcomingAppointments {
    return filteredAppointments.where((appointment) => appointment.isFuture).toList();
  }

  List<Appointment> get pastAppointments {
    return filteredAppointments.where((appointment) => appointment.isPast).toList();
  }

  bool get hasAppointments => filteredAppointments.isNotEmpty;
}

class AppointmentCreated extends DoctorState {
  final Appointment appointment;

  const AppointmentCreated(this.appointment);

  @override
  List<Object> get props => [appointment];
}

class DoctorError extends DoctorState {
  final String message;

  const DoctorError(this.message);

  @override
  List<Object> get props => [message];
}