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
    // Handle potentially large IDs
    final id = json['id'] is String 
        ? int.parse(json['id']) 
        : (json['id'] as num).toInt();
    
    return UserModel(
      id: id,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      password: json['password'] as String?,
    );
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