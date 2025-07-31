import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/appointment_entity.dart';
import '../../domain/repositories/doctor_repository.dart';
import '../datasources/doctor_remote_datasource.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final DoctorRemoteDataSource remoteDataSource;

  DoctorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Appointment>>> getDoctorAppointments(int doctorId) async {
    try {
      final appointmentModels = await remoteDataSource.getDoctorAppointments(doctorId);
      
      // Convert models to entities
      final appointments = appointmentModels.map((model) => model.toEntity()).toList();
      
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al obtener citas'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment({
    required int doctorId,
    required String patientName,
    required DateTime date,
  }) async {
    try {
      final appointmentModel = await remoteDataSource.createAppointment(
        doctorId: doctorId,
        patientName: patientName,
        date: date,
      );
      
      // Convert model to entity
      final appointment = appointmentModel.toEntity();
      
      return Right(appointment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al crear cita'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> filterAppointmentsByDateRange({
    required int doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final appointmentModels = await remoteDataSource.getDoctorAppointments(doctorId);
      
      // Filter by date range locally and convert to entities
      final filteredAppointments = appointmentModels
          .where((model) {
            final appointmentDate = DateTime.parse(model.dateString);
            return appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endDate.add(const Duration(days: 1)));
          })
          .map((model) => model.toEntity())
          .toList();

      return Right(filteredAppointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Error al filtrar citas'));
    }
  }
}