import 'package:flutter/material.dart';

import '../../../auth/domain/entities/appointment_entity.dart';

class AppointmentDetailsPage extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailsPage({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade800,
              Colors.teal.shade600,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Detalles de la Cita',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  size: 50,
                  color: Colors.teal.shade800,
                ),
              ),
              const SizedBox(height: 32),

              // Details Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Title
                        Text(
                          'Información de la Cita',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Patient Name
                        _buildDetailItem(
                          context,
                          icon: Icons.person_outline,
                          label: 'Paciente',
                          value: appointment.patientName,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(height: 20),

                        // Date
                        _buildDetailItem(
                          context,
                          icon: Icons.calendar_today_rounded,
                          label: 'Fecha',
                          value: appointment.formattedDate,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(height: 20),

                        // Time
                        _buildDetailItem(
                          context,
                          icon: Icons.access_time_rounded,
                          label: 'Hora',
                          value: appointment.formattedTime,
                          color: Colors.orange.shade600,
                        ),
                        const SizedBox(height: 20),

                        // Status
                        _buildDetailItem(
                          context,
                          icon: _getStatusIcon(),
                          label: 'Estado',
                          value: _getStatusText(),
                          color: _getStatusColor(),
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 32),

                        // Status Banner
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getStatusColor().withValues(alpha: 0.1),
                                _getStatusColor().withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getStatusColor().withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getStatusIcon(),
                                color: _getStatusColor(),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _getStatusMessage(),
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (appointment.isToday) {
      return Colors.orange.shade600;
    } else if (appointment.isFuture) {
      return Colors.green.shade600;
    } else {
      return Colors.grey.shade500;
    }
  }

  IconData _getStatusIcon() {
    if (appointment.isToday) {
      return Icons.today_rounded;
    } else if (appointment.isFuture) {
      return Icons.schedule_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  String _getStatusText() {
    if (appointment.isToday) {
      return 'Hoy';
    } else if (appointment.isFuture) {
      return 'Programada';
    } else {
      return 'Completada';
    }
  }

  String _getStatusMessage() {
    if (appointment.isToday) {
      return 'Cita programada para hoy';
    } else if (appointment.isFuture) {
      return 'Cita programada';
    } else {
      return 'Cita completada';
    }
  }
}