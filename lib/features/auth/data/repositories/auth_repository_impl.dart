import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/storage_service.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save user data locally
      await localDataSource.saveUserData(userModel);
      await storageService.saveUserType(userModel.type);

      // Convert model to appropriate entity
      User userEntity;
      if (userModel is PatientModel) {
        userEntity = userModel.toEntity();
      } else if (userModel is DoctorModel) {
        userEntity = userModel.toEntity();
      } else {
        // Generic user - this should not happen for login
        userEntity = User(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          phone: userModel.phone,
          type: userModel.type,
        );
      }

      return Right(userEntity);
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, Doctor>> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required double rating,
  }) async {
    try {
      final doctor = await remoteDataSource.registerDoctor(
        name: name,
        email: email,
        phone: phone,
        password: password,
        specialty: specialty,
        rating: rating,
      );

      // Convert to UserModel for storage
      final userModel = UserModel(
        id: doctor.id,
        name: doctor.name,
        email: doctor.email,
        phone: doctor.phone,
        type: doctor.type,
      );
      
      await localDataSource.saveUserData(userModel);
      await storageService.saveUserType(doctor.type);

      return Right(doctor.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, Patient>> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    required DateTime birthdate,
  }) async {
    try {
      final patient = await remoteDataSource.registerPatient(
        name: name,
        email: email,
        phone: phone,
        password: password,
        birthdate: birthdate,
      );

      // Convert to UserModel for storage
      final userModel = UserModel(
        id: patient.id,
        name: patient.name,
        email: patient.email,
        phone: patient.phone,
        type: patient.type,
      );
      
      await localDataSource.saveUserData(userModel);
      await storageService.saveUserType(patient.type);

      return Right(patient.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearUserData();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUserData();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return const Left(CacheFailure('Error al obtener usuario actual'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await localDataSource.isAuthenticated();
      return Right(isAuth);
    } catch (e) {
      return const Right(false);
    }
  }
}