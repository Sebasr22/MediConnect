import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_doctor_usecase.dart';
import '../../features/auth/domain/usecases/register_patient_usecase.dart';
import '../../features/doctor/data/datasources/doctor_remote_datasource.dart';
import '../../features/doctor/data/repositories/doctor_repository_impl.dart';
import '../../features/doctor/domain/repositories/doctor_repository.dart';
import '../../features/doctor/domain/usecases/create_appointment_usecase.dart';
import '../../features/doctor/domain/usecases/get_doctor_appointments_usecase.dart';
import '../../features/patient/data/datasources/patient_remote_datasource.dart';
import '../../features/patient/data/repositories/patient_repository_impl.dart';
import '../../features/patient/domain/repositories/patient_repository.dart';
import '../../features/patient/domain/usecases/get_doctor_by_id_usecase.dart';
import '../../features/patient/domain/usecases/get_doctors_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/patient/presentation/bloc/patient_bloc.dart';
import '../../features/doctor/presentation/bloc/doctor_bloc.dart';
import '../network/dio_client.dart';
import '../storage/storage_service.dart';
import 'constants.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Dio configuration
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(
        milliseconds: AppConstants.connectionTimeout,
      ),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  getIt.registerLazySingleton<Dio>(() => dio);

  // Core services
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));
  getIt.registerLazySingleton<StorageService>(
    () => StorageService(secureStorage: getIt(), sharedPreferences: getIt()),
  );

  // Initialize feature dependencies
  await _initAuthDependencies();
  await _initPatientDependencies();
  await _initDoctorDependencies();
}

Future<void> _initAuthDependencies() async {
  // Auth datasources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );

  // Auth repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      storageService: getIt(),
    ),
  );

  // Auth use cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterPatientUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterDoctorUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // Auth bloc
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerDoctorUseCase: getIt(),
      registerPatientUseCase: getIt(),
      logoutUseCase: getIt(),
    ),
  );
}

Future<void> _initPatientDependencies() async {
  // Patient datasources
  getIt.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(getIt()),
  );

  // Patient repository
  getIt.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(remoteDataSource: getIt()),
  );

  // Patient use cases
  getIt.registerLazySingleton(() => GetDoctorsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetDoctorByIdUseCase(getIt()));

  // Patient bloc
  getIt.registerFactory(
    () => PatientBloc(
      getDoctorsUseCase: getIt(),
      getDoctorByIdUseCase: getIt(),
    ),
  );
}

Future<void> _initDoctorDependencies() async {
  // Doctor datasources
  getIt.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(getIt()),
  );

  // Doctor repository
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(remoteDataSource: getIt()),
  );

  // Doctor use cases
  getIt.registerLazySingleton(() => GetDoctorAppointmentsUseCase(getIt()));
  getIt.registerLazySingleton(() => CreateAppointmentUseCase(getIt()));

  // Doctor bloc
  getIt.registerFactory(
    () => DoctorBloc(
      getDoctorAppointmentsUseCase: getIt(),
      createAppointmentUseCase: getIt(),
    ),
  );
}
