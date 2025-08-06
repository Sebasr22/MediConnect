import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/appointment_entity.dart';
import '../../domain/usecases/get_doctor_appointments_usecase.dart';
import '../../domain/usecases/create_appointment_usecase.dart';
import '../../../../core/error/failures.dart';

part 'doctor_event.dart';
part 'doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetDoctorAppointmentsUseCase getDoctorAppointmentsUseCase;
  final CreateAppointmentUseCase createAppointmentUseCase;

  DoctorBloc({
    required this.getDoctorAppointmentsUseCase,
    required this.createAppointmentUseCase,
  }) : super(DoctorInitial()) {
    on<GetAppointmentsRequested>(_onGetAppointmentsRequested);
    on<CreateAppointmentRequested>(_onCreateAppointmentRequested);
    on<FilterAppointmentsByDateRequested>(_onFilterAppointmentsByDateRequested);
    on<UpdateAppointmentRequested>(_onUpdateAppointmentRequested);
  }

  Future<void> _onGetAppointmentsRequested(
    GetAppointmentsRequested event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());

    final result = await getDoctorAppointmentsUseCase(event.doctorId);

    result.fold(
      (failure) => emit(DoctorError(_mapFailureToMessage(failure))),
      (appointments) => emit(AppointmentsLoaded(
        appointments: appointments,
        filteredAppointments: appointments,
      )),
    );
  }

  Future<void> _onCreateAppointmentRequested(
    CreateAppointmentRequested event,
    Emitter<DoctorState> emit,
  ) async {
    emit(CreatingAppointment());

    try {
      final result = await createAppointmentUseCase(
        CreateAppointmentParams(
          doctorId: event.doctorId,
          patientName: event.patientName,
          date: event.date,
        ),
      );

      result.fold(
        (failure) {
          emit(DoctorError(_mapFailureToMessage(failure)));
        },
        (newAppointment) {
          // First emit success for UI feedback
          emit(AppointmentCreated(newAppointment));
          // Then refresh appointments list
          add(GetAppointmentsRequested(event.doctorId));
        },
      );
    } catch (e) {
      emit(const DoctorError('Error inesperado al crear la cita'));
    }
  }

  Future<void> _onFilterAppointmentsByDateRequested(
    FilterAppointmentsByDateRequested event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is AppointmentsLoaded) {
      final currentState = state as AppointmentsLoaded;

      if (event.startDate == null || event.endDate == null) {
        emit(currentState.copyWith(filteredAppointments: currentState.appointments));
      } else {
        final filteredAppointments = currentState.appointments.where((appointment) {
          return appointment.date.isAfter(event.startDate!.subtract(const Duration(days: 1))) &&
                 appointment.date.isBefore(event.endDate!.add(const Duration(days: 1)));
        }).toList();

        emit(currentState.copyWith(filteredAppointments: filteredAppointments));
      }
    }
  }

  Future<void> _onUpdateAppointmentRequested(
    UpdateAppointmentRequested event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is AppointmentsLoaded) {
      final currentState = state as AppointmentsLoaded;
      emit(UpdatingAppointment());

      // Simulate update for now until backend is ready
      await Future.delayed(const Duration(seconds: 1));

      try {
        // Find and update the appointment in the list
        final updatedAppointments = currentState.appointments.map((appointment) {
          if (appointment.id == event.appointmentId) {
            return Appointment(
              id: appointment.id,
              doctorId: appointment.doctorId,
              patientName: event.patientName,
              date: event.date,
            );
          }
          return appointment;
        }).toList();

        // Update filtered appointments as well
        final updatedFilteredAppointments = currentState.filteredAppointments.map((appointment) {
          if (appointment.id == event.appointmentId) {
            return Appointment(
              id: appointment.id,
              doctorId: appointment.doctorId,
              patientName: event.patientName,
              date: event.date,
            );
          }
          return appointment;
        }).toList();

        final updatedAppointment = updatedAppointments.firstWhere(
          (appointment) => appointment.id == event.appointmentId,
        );

        // First emit the success state for the UI to handle
        emit(AppointmentUpdated(updatedAppointment));
        
        // Then update the appointments list
        emit(AppointmentsLoaded(
          appointments: updatedAppointments,
          filteredAppointments: updatedFilteredAppointments,
        ));
      } catch (e) {
        emit(const DoctorError('Error al actualizar la cita'));
      }
    } else {
      emit(const DoctorError('No se pudo actualizar la cita'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure():
        // Priorizar el mensaje específico del servidor si existe
        if (failure.message != null && failure.message!.isNotEmpty) {
          return failure.message!;
        }
        return 'Error del servidor. Intenta más tarde.';
      case ConnectionFailure():
        return 'Sin conexión a internet. Verifica tu conexión.';
      default:
        return 'Ha ocurrido un error inesperado.';
    }
  }
}