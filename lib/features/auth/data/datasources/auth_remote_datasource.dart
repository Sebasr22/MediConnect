import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/patient_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<DoctorModel> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required double rating,
  });

  Future<PatientModel> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    required DateTime birthdate,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {

      final response = await dioClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );


      if (response.statusCode == 200) {
        final userData = response.data['user'] ?? response.data;

        // Check user type and return appropriate model
        final userType = userData['type'] as String;

        try {
          if (userType == 'patient') {
            final patientModel = PatientModel.fromJson(userData);
            return patientModel;
          } else if (userType == 'doctor') {
            final doctorModel = DoctorModel.fromJson(userData);
            return doctorModel;
          } else {
            final userModel = UserModel.fromJson(userData);
            return userModel;
          }
        } catch (parseError) {
          throw ServerException('Error parsing user data: $parseError');
        }
      } else {
        throw ServerException(
          'Login failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 401) {
        throw const InvalidCredentialsException('Credenciales inválidas');
      }
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<DoctorModel> registerDoctor({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String specialty,
    required double rating,
  }) async {
    try {

      final requestData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'type': 'doctor',
        'specialty': specialty,
        'rating': rating,
      };


      final response = await dioClient.post(
        '/auth/register',
        data: requestData,
      );


      if (response.statusCode == 200) {
        final userData = response.data is Map
            ? (response.data['user'] ?? response.data)
            : response.data;

        return DoctorModel.fromJson(userData);
      } else {
        throw ServerException(
          'Registration failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 400) {
        throw const ValidationException('Email ya registrado');
      }
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<PatientModel> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String password,
    required DateTime birthdate,
  }) async {
    try {

      final requestData = {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'type': 'patient',
        'birthdate': birthdate.toIso8601String().split('T')[0], // YYYY-MM-DD
      };


      final response = await dioClient.post(
        '/auth/register',
        data: requestData,
      );


      if (response.statusCode == 200) {
        final userData = response.data is Map
            ? (response.data['user'] ?? response.data)
            : response.data;

        return PatientModel.fromJson(userData);
      } else {
        throw ServerException(
          'Registration failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {

      if (e.response?.statusCode == 400) {
        throw const ValidationException('Email ya registrado');
      }
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
