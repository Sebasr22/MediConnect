import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/error/failures.dart';
import '../../../doctor/presentation/bloc/doctor_bloc.dart';
import '../../../patient/presentation/bloc/patient_bloc.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      // Primero limpiar el almacenamiento
      final result = await repository.logout();
      
      return result.fold(
        (failure) => Left(failure),
        (_) async {
          // Si el logout fue exitoso, limpiar BLoCs de memoria
          await _resetBLoCs();
          return const Right(null);
        },
      );
    } catch (e) {
      return const Left(CacheFailure('Error al cerrar sesión'));
    }
  }

  /// Limpia todos los BLoCs para evitar contaminación entre usuarios
  Future<void> _resetBLoCs() async {
    try {
      final getIt = GetIt.instance;
      
      // Reset DoctorBloc si existe
      if (getIt.isRegistered<DoctorBloc>()) {
        // Cerrar streams antes de unregister
        try {
          final doctorBloc = getIt<DoctorBloc>();
          doctorBloc.close();
        } catch (e) {
          // Ignorar errores al cerrar
        }
        getIt.unregister<DoctorBloc>();
      }
      
      // Reset PatientBloc si existe
      if (getIt.isRegistered<PatientBloc>()) {
        // Cerrar streams antes de unregister
        try {
          final patientBloc = getIt<PatientBloc>();
          patientBloc.close();
        } catch (e) {
          // Ignorar errores al cerrar
        }
        getIt.unregister<PatientBloc>();
      }
      
    } catch (e) {
      // No fallar el logout por esto
    }
  }
}