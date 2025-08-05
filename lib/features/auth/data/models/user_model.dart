import 'dart:developer' as developer;
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  @JsonKey(name: 'password', includeToJson: false)
  final String? password;

  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.type,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle potentially large IDs safely
      final id = json['id'] is String 
          ? int.parse(json['id']) 
          : (json['id'] as num).toInt();
      
      // Infer user type if 'type' field is missing
      String? userType = json['type'] as String?;
      
      if (userType == null) {
        // Infer type based on present fields
        if (json.containsKey('specialty') && json.containsKey('rating')) {
          userType = 'doctor';
        } else if (json.containsKey('birthdate')) {
          userType = 'patient';
        } else {
          userType = 'user';
        }
      }
      
      // Safe handling of required fields with defaults and basic validation
      final name = (json['name'] as String? ?? 'Sin nombre').trim();
      final email = (json['email'] as String? ?? 'sin-email@ejemplo.com').trim().toLowerCase();
      final phone = (json['phone'] as String? ?? 'Sin teléfono').trim();
      
      // Basic email format validation
      final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      final validEmail = emailPattern.hasMatch(email) ? email : 'sin-email@ejemplo.com';
      
      return UserModel(
        id: id > 0 ? id : 1, // Ensure positive ID
        name: name.isNotEmpty ? name : 'Sin nombre',
        email: validEmail,
        phone: phone.isNotEmpty ? phone : 'Sin teléfono',
        type: userType,
        password: json['password'] as String?,
      );
    } catch (e) {
      developer.log(
        'Error parsing UserModel',
        name: 'UserModel.fromJson',
        error: e,
        stackTrace: StackTrace.current,
      );
      
      // If parsing fails completely, create user with minimal valid data
      final id = json['id'] is String 
          ? int.tryParse(json['id']) ?? 1
          : (json['id'] as num?)?.toInt() ?? 1;
          
      return UserModel(
        id: id > 0 ? id : 1,
        name: 'Datos incompletos',
        email: 'datos-incompletos@ejemplo.com',
        phone: 'Sin teléfono',
        type: 'user',
      );
    }
  }
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      type: entity.type,
    );
  }
}