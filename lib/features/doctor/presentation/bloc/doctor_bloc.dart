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
    if (state is AppointmentsLoaded) {
      emit(CreatingAppointment());

      final result = await createAppointmentUseCase(
        CreateAppointmentParams(
          doctorId: event.doctorId,
          patientName: event.patientName,
          date: event.date,
        ),
      );

      result.fold(
        (failure) => emit(DoctorError(_mapFailureToMessage(failure))),
        (newAppointment) {
          // Refresh appointments list
          add(GetAppointmentsRequested(event.doctorId));
          emit(AppointmentCreated(newAppointment));
        },
      );
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

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message ?? 'Error del servidor. Intenta más tarde.';
      case ConnectionFailure:
        return 'Sin conexión a internet. Verifica tu conexión.';
      default:
        return 'Ha ocurrido un error inesperado.';
    }
  }
}