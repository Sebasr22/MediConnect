import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_doctor_usecase.dart';
import '../../domain/usecases/register_patient_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc que maneja el estado de autenticación de la aplicación
/// Gestiona login, registro de doctores/pacientes y logout
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterDoctorUseCase registerDoctorUseCase;
  final RegisterPatientUseCase registerPatientUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerDoctorUseCase,
    required this.registerPatientUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterDoctorRequested>(_onRegisterDoctorRequested);
    on<RegisterPatientRequested>(_onRegisterPatientRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterDoctorRequested(
    RegisterDoctorRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerDoctorUseCase(
      RegisterDoctorParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        specialty: event.specialty,
        rating: event.rating,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (doctor) => emit(AuthAuthenticated(doctor)),
    );
  }

  Future<void> _onRegisterPatientRequested(
    RegisterPatientRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerPatientUseCase(
      RegisterPatientParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        password: event.password,
        birthdate: event.birthdate,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (patient) => emit(AuthAuthenticated(patient)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await logoutUseCase();
    
    result.fold(
      (failure) {
        emit(AuthError(_mapFailureToMessage(failure)));
      },
      (_) {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // Verificar si el usuario ya está autenticado
    emit(AuthUnauthenticated());
  }

  /// Convierte los errores del dominio en mensajes legibles para el usuario
  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case InvalidCredentialsFailure():
        return 'Credenciales inválidas. Verifica tu email y contraseña.';
      case ValidationFailure():
        return failure.message ?? 'Datos inválidos. Verifica la información ingresada.';
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