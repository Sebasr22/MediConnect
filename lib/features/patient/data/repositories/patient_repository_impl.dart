import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/doctor_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Doctor>>> getAllDoctors() async {
    try {
      final doctorModels = await remoteDataSource.getAllDoctors();
      
      // Convert models to entities
      final doctors = doctorModels.map((model) => model.toEntity()).toList();
      
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Doctor>> getDoctorById(int doctorId) async {
    try {
      final doctorModel = await remoteDataSource.getDoctorById(doctorId);
      
      // Convert model to entity
      final doctor = doctorModel.toEntity();
      
      return Right(doctor);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}