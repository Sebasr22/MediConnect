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
      (doctors) {
        // Filtrar doctores con datos demasiado incompletos
        final validDoctors = doctors.where((doctor) {
          // Considerar válido si tiene al menos nombre real y especialidad
          final hasRealName = doctor.name != 'Sin nombre' && 
                             doctor.name != 'Datos incompletos' &&
                             doctor.name.isNotEmpty;
          final hasRealSpecialty = doctor.specialty != 'Sin especialidad' && 
                                  doctor.specialty.isNotEmpty;
          
          // Requiere al menos nombre o especialidad válidos
          return hasRealName || hasRealSpecialty;
        }).toList();
        
        emit(DoctorsLoaded(
          doctors: validDoctors,
          filteredDoctors: validDoctors,
        ));
      },
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
    print('🔎 SearchDoctorsRequested recibido con query: "${event.query}"'); // Debug log
    
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final query = event.query.toLowerCase().trim();
      
      print('📊 Estado actual: ${currentState.doctors.length} doctores disponibles'); // Debug log

      if (query.isEmpty) {
        print('🔄 Query vacío, mostrando todos los doctores'); // Debug log
        emit(currentState.copyWith(filteredDoctors: currentState.doctors));
      } else {
        final filteredDoctors = currentState.doctors.where((doctor) {
          // Valores por defecto que no queremos buscar
          final defaultValues = {'sin nombre', 'sin especialidad', 'datos incompletos'};
          
          final doctorName = doctor.name.toLowerCase();
          final doctorSpecialty = doctor.specialty.toLowerCase();
          
          // Búsqueda más flexible - remover acentos y caracteres especiales
          final normalizedQuery = _normalizeString(query);
          final normalizedName = _normalizeString(doctorName);
          final normalizedSpecialty = _normalizeString(doctorSpecialty);
          
          // Búsqueda por palabras individuales también
          final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty);
          
          bool nameMatch = false;
          bool specialtyMatch = false;
          
          if (!defaultValues.contains(doctorName)) {
            // Búsqueda exacta o por palabras
            nameMatch = normalizedName.contains(normalizedQuery) ||
                       queryWords.any((word) => normalizedName.contains(word));
          }
          
          if (!defaultValues.contains(doctorSpecialty)) {
            // Búsqueda exacta o por palabras
            specialtyMatch = normalizedSpecialty.contains(normalizedQuery) ||
                           queryWords.any((word) => normalizedSpecialty.contains(word));
          }
          
          final matches = nameMatch || specialtyMatch;
          
          if (matches) {
            print('✅ Match encontrado: ${doctor.name} - ${doctor.specialty}'); // Debug log
          }
          
          return matches;
        }).toList();

        print('📋 Resultados filtrados: ${filteredDoctors.length} doctores'); // Debug log
        emit(currentState.copyWith(filteredDoctors: filteredDoctors));
      }
    } else {
      print('❌ Estado no es DoctorsLoaded: ${state.runtimeType}'); // Debug log
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
    print('💥 Error detectado: ${failure.runtimeType} - ${failure.message}'); // Debug log
    
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message ?? 'Error del servidor. Intenta más tarde.';
      case ConnectionFailure:
        return failure.message ?? 'Sin conexión a internet. Verifica tu conexión.';
      default:
        // Incluir información específica del error
        final errorInfo = failure.message ?? failure.toString();
        return 'Error inesperado: ${failure.runtimeType}\nDetalle: $errorInfo';
    }
  }
  
  /// Normaliza un string removiendo acentos y caracteres especiales
  String _normalizeString(String input) {
    return input
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remover caracteres especiales
        .trim();
  }
}