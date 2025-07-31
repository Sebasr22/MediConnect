part of 'patient_bloc.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class DoctorsLoaded extends PatientState {
  final List<Doctor> doctors;
  final List<Doctor> filteredDoctors;

  const DoctorsLoaded({
    required this.doctors,
    required this.filteredDoctors,
  });

  @override
  List<Object> get props => [doctors, filteredDoctors];

  DoctorsLoaded copyWith({
    List<Doctor>? doctors,
    List<Doctor>? filteredDoctors,
  }) {
    return DoctorsLoaded(
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
    );
  }

  // Helper methods
  List<String> get specialties {
    return doctors
        .map((doctor) => doctor.specialty)
        .where((specialty) => 
            specialty != 'Sin especialidad' && 
            specialty.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  bool get hasResults => filteredDoctors.isNotEmpty;
}

class DoctorDetailLoading extends PatientState {}

class DoctorDetailLoaded extends PatientState {
  final Doctor doctor;

  const DoctorDetailLoaded(this.doctor);

  @override
  List<Object> get props => [doctor];
}

class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object> get props => [message];
}