import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/get_doctor_by_id_usecase.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/storage_service.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetDoctorsUseCase getDoctorsUseCase;
  final GetDoctorByIdUseCase getDoctorByIdUseCase;
  final StorageService storageService;

  PatientBloc({
    required this.getDoctorsUseCase,
    required this.getDoctorByIdUseCase,
    required this.storageService,
  }) : super(PatientInitial()) {
    on<GetDoctorsRequested>(_onGetDoctorsRequested);
    on<GetDoctorByIdRequested>(_onGetDoctorByIdRequested);
    on<SearchDoctorsRequested>(_onSearchDoctorsRequested);
    on<FilterDoctorsBySpecialtyRequested>(_onFilterDoctorsBySpecialtyRequested);
    on<ToggleFavoriteRequested>(_onToggleFavoriteRequested);
    on<LoadFavoritesRequested>(_onLoadFavoritesRequested);
    on<FilterFavoritesDoctorsRequested>(_onFilterFavoritesDoctorsRequested);
  }

  Future<void> _onGetDoctorsRequested(
    GetDoctorsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getDoctorsUseCase();

    await result.fold(
      (failure) async => emit(PatientError(_mapFailureToMessage(failure))),
      (doctors) async {
        final validDoctors = doctors.where((doctor) {
          final hasRealName = doctor.name != 'Sin nombre' && 
                             doctor.name != 'Datos incompletos' &&
                             doctor.name.isNotEmpty;
          final hasRealSpecialty = doctor.specialty != 'Sin especialidad' && 
                                  doctor.specialty.isNotEmpty;
          
          return hasRealName || hasRealSpecialty;
        }).toList();
        
        // Cargar favoritos junto con los doctores
        try {
          final favorites = await storageService.getFavoriteDoctors();
          emit(DoctorsLoaded(
            doctors: validDoctors,
            filteredDoctors: validDoctors,
            favoriteDoctorIds: favorites,
          ));
        } catch (e) {
          emit(DoctorsLoaded(
            doctors: validDoctors,
            filteredDoctors: validDoctors,
            favoriteDoctorIds: const [],
          ));
        }
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
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(currentState.copyWith(filteredDoctors: currentState.doctors));
      } else {
        final filteredDoctors = currentState.doctors.where((doctor) {
          final defaultValues = {'sin nombre', 'sin especialidad', 'datos incompletos'};
          
          final doctorName = doctor.name.toLowerCase();
          final doctorSpecialty = doctor.specialty.toLowerCase();
          
          final normalizedQuery = _normalizeString(query);
          final normalizedName = _normalizeString(doctorName);
          final normalizedSpecialty = _normalizeString(doctorSpecialty);
          
          final queryWords = normalizedQuery.split(' ').where((word) => word.isNotEmpty);
          
          bool nameMatch = false;
          bool specialtyMatch = false;
          
          if (!defaultValues.contains(doctorName)) {
            nameMatch = normalizedName.contains(normalizedQuery) ||
                       queryWords.any((word) => normalizedName.contains(word));
          }
          
          if (!defaultValues.contains(doctorSpecialty)) {
            specialtyMatch = normalizedSpecialty.contains(normalizedQuery) ||
                           queryWords.any((word) => normalizedSpecialty.contains(word));
          }
          
          return nameMatch || specialtyMatch;
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
      } else if (event.specialty == 'populares') {
        final popularDoctors = currentState.doctors.where((doctor) {
          return doctor.rating >= 4.0;
        }).toList();
        
        popularDoctors.sort((a, b) => b.rating.compareTo(a.rating));
        
        emit(currentState.copyWith(filteredDoctors: popularDoctors));
      } else if (event.specialty == 'favoritos') {
        final favoriteDoctors = currentState.favoriteDoctors;
        
        emit(currentState.copyWith(filteredDoctors: favoriteDoctors));
      } else {
        final filteredDoctors = currentState.doctors.where((doctor) {
          return doctor.specialty.toLowerCase() == event.specialty!.toLowerCase();
        }).toList();

        emit(currentState.copyWith(filteredDoctors: filteredDoctors));
      }
    }
  }

  Future<void> _onToggleFavoriteRequested(
    ToggleFavoriteRequested event,
    Emitter<PatientState> emit,
  ) async {
    if (state is! DoctorsLoaded) {
      return;
    }
    
    try {
      final currentState = state as DoctorsLoaded;
      await storageService.toggleFavoriteDoctor(event.doctorId);
      final updatedFavorites = await storageService.getFavoriteDoctors();
      
      List<Doctor> updatedFilteredDoctors = currentState.filteredDoctors;
      
      if (currentState.filteredDoctors.length != currentState.doctors.length) {
        final favoriteDoctors = currentState.doctors
            .where((doctor) => updatedFavorites.contains(doctor.id.toString()))
            .toList();
        
        if (currentState.filteredDoctors.length == currentState.favoriteDoctors.length) {
          updatedFilteredDoctors = favoriteDoctors;
        }
      }
      emit(currentState.copyWith(
        favoriteDoctorIds: updatedFavorites,
        filteredDoctors: updatedFilteredDoctors,
      ));
      
    } catch (e) {
      emit(PatientError('Error al cambiar favorito: $e'));
    }
  }

  Future<void> _onLoadFavoritesRequested(
    LoadFavoritesRequested event,
    Emitter<PatientState> emit,
  ) async {
    try {
      final favorites = await storageService.getFavoriteDoctors();
      
      if (state is DoctorsLoaded) {
        final currentState = state as DoctorsLoaded;
        emit(currentState.copyWith(favoriteDoctorIds: favorites));
      }
      
    } catch (e) {
      emit(PatientError('Error al cargar favoritos: $e'));
    }
  }

  Future<void> _onFilterFavoritesDoctorsRequested(
    FilterFavoritesDoctorsRequested event,
    Emitter<PatientState> emit,
  ) async {
    if (state is DoctorsLoaded) {
      final currentState = state as DoctorsLoaded;
      final favoriteDoctors = currentState.favoriteDoctors;
      
      emit(currentState.copyWith(filteredDoctors: favoriteDoctors));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return failure.message ?? 'Error del servidor. Intenta más tarde.';
      case ConnectionFailure _:
        return failure.message ?? 'Sin conexión a internet. Verifica tu conexión.';
      default:
        // Incluir información específica del error
        final errorInfo = failure.message ?? failure.toString();
        return 'Error inesperado: ${failure.runtimeType}\nDetalle: $errorInfo';
    }
  }
  
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