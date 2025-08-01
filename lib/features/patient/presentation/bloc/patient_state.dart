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
  final List<String> favoriteDoctorIds;

  const DoctorsLoaded({
    required this.doctors,
    required this.filteredDoctors,
    this.favoriteDoctorIds = const [],
  });

  @override
  List<Object> get props => [doctors, filteredDoctors, favoriteDoctorIds];

  DoctorsLoaded copyWith({
    List<Doctor>? doctors,
    List<Doctor>? filteredDoctors,
    List<String>? favoriteDoctorIds,
  }) {
    return DoctorsLoaded(
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      favoriteDoctorIds: favoriteDoctorIds ?? this.favoriteDoctorIds,
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
  
  bool isDoctorFavorite(String doctorId) => favoriteDoctorIds.contains(doctorId);
  
  List<Doctor> get favoriteDoctors {
    return doctors.where((doctor) => favoriteDoctorIds.contains(doctor.id.toString())).toList();
  }
  
  int get favoritesCount => favoriteDoctorIds.length;
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

class FavoriteToggled extends PatientState {
  final String doctorId;
  final bool isFavorite;

  const FavoriteToggled({
    required this.doctorId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [doctorId, isFavorite];
}