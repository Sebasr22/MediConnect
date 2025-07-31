import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/doctor_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<DoctorModel>> getAllDoctors();
  Future<DoctorModel> getDoctorById(int doctorId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient dioClient;

  PatientRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final response = await dioClient.get('/patients/doctors');

      if (response.statusCode == 200) {
        final List<dynamic> doctorsJson = response.data;
        return doctorsJson
            .map((doctorJson) => DoctorModel.fromJson(doctorJson))
            .toList();
      } else {
        throw ServerException('Error al obtener doctores - Código: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw const ServerException('Tiempo de respuesta agotado');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const ServerException('Error de conexión a internet');
      } else {
        throw ServerException('Error del servidor: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Error inesperado al procesar doctores: $e');
    }
  }

  @override
  Future<DoctorModel> getDoctorById(int doctorId) async {
    try {
      final response = await dioClient.get('/patients/doctors/$doctorId');

      if (response.statusCode == 200) {
        return DoctorModel.fromJson(response.data);
      } else {
        throw const ServerException('Error al obtener doctor');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const ServerException('Médico no encontrado');
      }
      throw const ServerException('Error del servidor');
    } catch (e) {
      throw const ServerException('Error inesperado');
    }
  }
}