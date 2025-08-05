import 'dart:developer' as developer;
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/doctor_entity.dart';
import 'user_model.dart';

part 'doctor_model.g.dart';

/// Modelo de datos para doctores con serialización JSON
@JsonSerializable()
class DoctorModel extends UserModel {
  final String specialty;
  final double rating;

  const DoctorModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required this.specialty,
    required this.rating,
    super.password,
  }) : super(type: 'doctor');

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    try {
      // Manejo de IDs grandes que pueden venir como String o número
      final id = json['id'] is String 
          ? int.parse(json['id']) 
          : (json['id'] as num).toInt();
      
      // Manejo seguro de rating con valor por defecto y validación de rango
      final ratingValue = json['rating'];
      double rating = ratingValue != null ? (ratingValue as num).toDouble() : 0.0;
      rating = rating.clamp(0.0, 5.0); // Ensure rating is between 0-5
      
      // Manejo seguro de specialty con valor por defecto
      final specialty = (json['specialty'] as String? ?? 'Sin especialidad').trim();
      
      // Manejo seguro de campos requeridos con valores por defecto y validación básica
      final name = (json['name'] as String? ?? 'Sin nombre').trim();
      final email = (json['email'] as String? ?? 'sin-email@ejemplo.com').trim().toLowerCase();
      final phone = (json['phone'] as String? ?? 'Sin teléfono').trim();
      
      // Basic email format validation
      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final validEmail = emailPattern.hasMatch(email) ? email : 'sin-email@ejemplo.com';
      
      return DoctorModel(
        id: id > 0 ? id : 1,
        name: name.isNotEmpty ? name : 'Sin nombre',
        email: validEmail,
        phone: phone.isNotEmpty ? phone : 'Sin teléfono',
        specialty: specialty.isNotEmpty ? specialty : 'Sin especialidad',
        rating: rating,
        password: json['password'] as String?,
      );
    } catch (e) {
      developer.log(
        'Error parsing DoctorModel',
        name: 'DoctorModel.fromJson',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      // If parsing fails completely, create doctor with minimal valid data
      final id = json['id'] is String 
          ? int.tryParse(json['id']) ?? 1
          : (json['id'] as num?)?.toInt() ?? 1;
          
      return DoctorModel(
        id: id > 0 ? id : 1,
        name: 'Datos incompletos',
        email: 'datos-incompletos@ejemplo.com',
        phone: 'Sin teléfono',
        specialty: 'Sin especialidad',
        rating: 0.0,
      );
    }
  }
  
  @override
  Map<String, dynamic> toJson() => _$DoctorModelToJson(this);

  /// Convierte el modelo a entidad del dominio
  Doctor toEntity() {
    return Doctor(
      id: id,
      name: name,
      email: email,
      phone: phone,
      specialty: specialty,
      rating: rating,
    );
  }

  factory DoctorModel.fromEntity(Doctor entity) {
    return DoctorModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      specialty: entity.specialty,
      rating: entity.rating,
    );
  }
}