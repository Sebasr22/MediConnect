import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final int id;
  final int doctorId;
  final String patientName;
  final DateTime date;

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.patientName,
    required this.date,
  });

  @override
  List<Object> get props => [id, doctorId, patientName, date];

  // Helper methods
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  bool get isFuture {
    return date.isAfter(DateTime.now());
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}