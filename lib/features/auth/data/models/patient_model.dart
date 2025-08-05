import 'dart:developer' as developer;
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/patient_entity.dart';
import 'user_model.dart';

part 'patient_model.g.dart';

@JsonSerializable()
class PatientModel extends UserModel {
  @JsonKey(name: 'birthdate')
  final String birthdateString;

  const PatientModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required this.birthdateString,
    super.password,
  }) : super(type: 'patient');

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle potentially large IDs
      final id = json['id'] is String 
          ? int.parse(json['id']) 
          : (json['id'] as num).toInt();
      
      // Manejo seguro de campos requeridos con valores por defecto
      final name = json['name'] as String? ?? 'Sin nombre';
      final email = json['email'] as String? ?? 'Sin email';
      final phone = json['phone'] as String? ?? 'Sin teléfono';
      final birthdate = json['birthdate'] as String? ?? '2000-01-01';
      final password = json['password'] as String?;
      
      return PatientModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        birthdateString: birthdate,
        password: password,
      );
    } catch (e) {
      developer.log(
        'Error parsing PatientModel',
        name: 'PatientModel.fromJson',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      // Si falla el parsing, crear un paciente con datos mínimos válidos
      final id = json['id'] is String 
          ? int.tryParse(json['id']) ?? 1
          : (json['id'] as num?)?.toInt() ?? 1;
          
      return PatientModel(
        id: id > 0 ? id : 1,
        name: 'Datos incompletos',
        email: 'datos-incompletos@ejemplo.com',
        phone: 'Sin teléfono',
        birthdateString: '2000-01-01',
      );
    }
  }
  
  @override
  Map<String, dynamic> toJson() => _$PatientModelToJson(this);

  // Convert to domain entity
  Patient toEntity() {
    try {
      return Patient(
        id: id,
        name: name,
        email: email,
        phone: phone,
        birthdate: DateTime.parse(birthdateString),
      );
    } catch (e) {
      developer.log(
        'Error parsing birthdate: $birthdateString',
        name: 'PatientModel.toEntity',
        error: e,
      );
      
      // Si falla el parsing de fecha, usar fecha por defecto
      return Patient(
        id: id,
        name: name,
        email: email,
        phone: phone,
        birthdate: DateTime(2000, 1, 1),
      );
    }
  }

  factory PatientModel.fromEntity(Patient entity) {
    return PatientModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      birthdateString: entity.birthdate.toIso8601String().split('T')[0],
    );
  }
}