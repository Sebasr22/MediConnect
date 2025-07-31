import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/appointment_model.dart';

abstract class DoctorRemoteDataSource {
  Future<List<AppointmentModel>> getDoctorAppointments(int doctorId);
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required String patientName,
    required DateTime date,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final DioClient dioClient;

  DoctorRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<AppointmentModel>> getDoctorAppointments(int doctorId) async {
    try {
      final response = await dioClient.get('/doctors/$doctorId/appointments');

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsJson = response.data;
        return appointmentsJson
            .map((appointmentJson) => AppointmentModel.fromJson(appointmentJson))
            .toList();
      } else {
        throw const ServerException('Error al obtener citas');
      }
    } on DioException catch (_) {
      throw const ServerException('Error del servidor');
    } catch (e) {
      throw const ServerException('Error inesperado');
    }
  }

  @override
  Future<AppointmentModel> createAppointment({
    required int doctorId,
    required String patientName,
    required DateTime date,
  }) async {
    try {
      final requestData = {
        'patientName': patientName,
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      };

      final response = await dioClient.post(
        '/doctors/$doctorId/appointments',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final appointmentData = response.data['appointment'] ?? response.data;
        return AppointmentModel.fromJson(appointmentData);
      } else {
        throw const ServerException('Error al crear cita');
      }
    } on DioException catch (_) {
      throw const ServerException('Error del servidor');
    } catch (e) {
      throw const ServerException('Error inesperado');
    }
  }
}