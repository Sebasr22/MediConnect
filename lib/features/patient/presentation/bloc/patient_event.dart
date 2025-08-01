part of 'patient_bloc.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class GetDoctorsRequested extends PatientEvent {}

class GetDoctorByIdRequested extends PatientEvent {
  final int doctorId;

  const GetDoctorByIdRequested(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}

class SearchDoctorsRequested extends PatientEvent {
  final String query;

  const SearchDoctorsRequested(this.query);

  @override
  List<Object> get props => [query];
}

class FilterDoctorsBySpecialtyRequested extends PatientEvent {
  final String? specialty;

  const FilterDoctorsBySpecialtyRequested(this.specialty);

  @override
  List<Object?> get props => [specialty];
}

class ToggleFavoriteRequested extends PatientEvent {
  final String doctorId;

  const ToggleFavoriteRequested(this.doctorId);

  @override
  List<Object> get props => [doctorId];
}

class LoadFavoritesRequested extends PatientEvent {}

class FilterFavoritesDoctorsRequested extends PatientEvent {}