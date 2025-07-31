part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterDoctorRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String specialty;
  final double rating;

  const RegisterDoctorRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.specialty,
    required this.rating,
  });

  @override
  List<Object> get props => [name, email, phone, password, specialty, rating];
}

class RegisterPatientRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final DateTime birthdate;

  const RegisterPatientRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.birthdate,
  });

  @override
  List<Object> get props => [name, email, phone, password, birthdate];
}

class LogoutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}