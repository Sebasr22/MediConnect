import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/get_doctor_by_id_usecase.dart';
import '../../../../core/error/failures.dart';

part 'patient_event.dart';
part 'patient_state.dart';

/// Bloc que maneja el estado y funcionalidades para pacientes
/// Gestiona la búsqueda y filtrado de doctores
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetDoctorsUseCase getDoctorsUseCase;
  final GetDoctorByIdUseCase getDoctorByIdUseCase;

  PatientBloc({
    required this.getDoctorsUseCase,
    required this.getDoctorByIdUseCase,
  }) : super(PatientInitial()) {
    on<GetDoctorsRequested>(_onGetDoctorsRequested);
    on<GetDoctorByIdRequested>(_onGetDoctorByIdRequested);
    on<SearchDoctorsRequested>(_onSearchDoctorsRequested);
    on<FilterDoctorsBySpecialtyRequested>(_onFilterDoctorsBySpecialtyRequested);
  }

  Future<void> _onGetDoctorsRequested(
    GetDoctorsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getDoctorsUseCase();

    result.fold(
      (failure) => emit(PatientError(_mapFailureToMessage(failure))),
      (doctors) => emit(DoctorsLoaded(
        doctors: doctors,
        filteredDoctors: doctors,
      )),
    );
  }

  Future<void> _onGetDoctorByIdRequested(
    GetDoctorByIdRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(DoctorDetailLoading());

    final result = await getDoctorByIdUseCase(event.doctorId);

    result.fold(
      (failure) => emit(PatientError(_mapFailureToMessage(failure))),
      (doctor) => emit(DoctorDetailLoaded(doctor)),
    );
  }

  Future<void> _onSearchDoctorsRequested(
    SearchDoctorsRequested event,
    Emitter<PatientState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final query = event.query.toLowerCase();

      if (query.isEmpty) {
        emit(currentState.copyWith(filteredDoctors: currentState.doctors));
      } else {
        final filteredDoctors = currentState.doctors.where((doctor) {
          return doctor.name.toLowerCase().contains(query) ||
                 doctor.specialty.toLowerCase().contains(query);
        }).toList();

        emit(currentState.copyWith(filteredDoctors: filteredDoctors));
      }
    }
  }

  Future<void> _onFilterDoctorsBySpecialtyRequested(
    FilterDoctorsBySpecialtyRequested event,
    Emitter<PatientState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;

      if (event.specialty == null || event.specialty!.isEmpty) {
        emit(currentState.copyWith(filteredDoctors: currentState.doctors));
      } else {
        final filteredDoctors = currentState.doctors.where((doctor) {
          return doctor.specialty.toLowerCase() == event.specialty!.toLowerCase();
        }).toList();

        emit(currentState.copyWith(filteredDoctors: filteredDoctors));
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