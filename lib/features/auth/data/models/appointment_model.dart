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
    date: DateTime.parse(dateString),
  );

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  // Convert to domain entity
  Appointment toEntity() {
    return Appointment(
      id: id,
      doctorId: doctorIdField,
      patientName: patientNameField,
      date: DateTime.parse(dateString),
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