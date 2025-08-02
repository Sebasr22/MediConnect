import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/appointment_entity.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel extends Appointment {
  @JsonKey(name: 'doctorId')
  final int doctorIdField;
  
  @JsonKey(name: 'patientName')
  final String patientNameField;
  
  @JsonKey(name: 'date')
  final String dateString;

  AppointmentModel({
    required super.id,
    required this.doctorIdField,
    required this.patientNameField,
    required this.dateString,
  }) : super(
    doctorId: doctorIdField,
    patientName: patientNameField,
    date: _parseDate(dateString),
  );

  static DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // If date parsing fails, return current date
      return DateTime.now();
    }
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle potentially large IDs
      final id = json['id'] is String 
          ? int.parse(json['id']) 
          : (json['id'] as num).toInt();
      
      // Safe handling of required fields with defaults
      final doctorId = json['doctorId'] is String 
          ? int.parse(json['doctorId']) 
          : (json['doctorId'] as num?)?.toInt() ?? 0;
      
      final patientName = json['patientName'] as String? ?? 'Sin nombre';
      final dateString = json['date'] as String? ?? DateTime.now().toIso8601String().split('T')[0];
      
      return AppointmentModel(
        id: id,
        doctorIdField: doctorId,
        patientNameField: patientName,
        dateString: dateString,
      );
    } catch (e) {
      // If parsing fails, create appointment with minimal valid data
      final id = json['id'] is String 
          ? int.tryParse(json['id']) ?? 0
          : (json['id'] as num?)?.toInt() ?? 0;
          
      return AppointmentModel(
        id: id,
        doctorIdField: 0,
        patientNameField: 'Datos incompletos',
        dateString: DateTime.now().toIso8601String().split('T')[0],
      );
    }
  }
  
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  // Convert to domain entity
  Appointment toEntity() {
    return Appointment(
      id: id,
      doctorId: doctorIdField,
      patientName: patientNameField,
      date: _parseDate(dateString),
    );
  }

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      id: entity.id,
      doctorIdField: entity.doctorId,
      patientNameField: entity.patientName,
      dateString: entity.date.toIso8601String().split('T')[0],
    );
  }
}