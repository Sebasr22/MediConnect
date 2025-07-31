import 'user_entity.dart';

class Patient extends User {
  final DateTime birthdate;

  const Patient({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required this.birthdate,
  }) : super(type: 'patient');

  @override
  List<Object> get props => [
    ...super.props,
    birthdate,
  ];

  // Helper method to calculate age
  int get age {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }
}