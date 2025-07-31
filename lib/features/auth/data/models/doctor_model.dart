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
    // Manejo de IDs grandes que pueden venir como String o número
    final id = json['id'] is String 
        ? int.parse(json['id']) 
        : (json['id'] as num).toInt();
    
    // Manejo seguro de rating con valor por defecto
    final ratingValue = json['rating'];
    final rating = ratingValue != null ? (ratingValue as num).toDouble() : 0.0;
    
    // Manejo seguro de specialty con valor por defecto
    final specialty = json['specialty'] as String? ?? 'Sin especialidad';
    
    // Manejo seguro de campos requeridos con valores por defecto
    final name = json['name'] as String? ?? 'Sin nombre';
    final email = json['email'] as String? ?? 'Sin email';
    final phone = json['phone'] as String? ?? 'Sin teléfono';
    
    return DoctorModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      specialty: specialty,
      rating: rating,
      password: json['password'] as String?,
    );
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