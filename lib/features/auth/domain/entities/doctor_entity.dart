import 'user_entity.dart';

class Doctor extends User {
  final String specialty;
  final double rating;

  const Doctor({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required this.specialty,
    required this.rating,
  }) : super(type: 'doctor');

  @override
  List<Object> get props => [
    ...super.props,
    specialty,
    rating,
  ];
}