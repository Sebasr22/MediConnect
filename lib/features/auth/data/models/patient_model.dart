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
      
      final name = json['name'] as String;
      final email = json['email'] as String;
      final phone = json['phone'] as String;
      final birthdate = json['birthdate'] as String;
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
      rethrow;
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
      rethrow;
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