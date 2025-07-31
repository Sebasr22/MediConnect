import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/injection.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/doctor_bloc.dart';
import '../widgets/appointment_card.dart';
import '../widgets/appointment_stats.dart';
import '../widgets/date_filter.dart';
import 'create_appointment_page.dart';

class DoctorDashboard extends StatefulWidget {
  final User doctor; // The logged-in doctor

  const DoctorDashboard({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DoctorBloc>()
        ..add(GetAppointmentsRequested(widget.doctor.id)),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.teal.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade100,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.teal.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${widget.doctor.name}',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                                Text(
                                  'Panel de Control',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // Implementar logout
                            },
                            icon: Icon(
                              Icons.logout,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: BlocBuilder<DoctorBloc, DoctorState>(
                    builder: (context, state) {
                      if (state is DoctorLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is DoctorError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<DoctorBloc>().add(
                                    GetAppointmentsRequested(widget.doctor.id),
                                  );
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is AppointmentsLoaded) {
                        return Column(
                          children: [
                            // Stats
                            AppointmentStats(
                              totalAppointments: state.appointments.length,
                              todayAppointments: state.todayAppointments.length,
                              upcomingAppointments: state.upcomingAppointments.length,
                            ),

                            // Date Filter
                            DateFilter(
                              onDateRangeSelected: (startDate, endDate) {
                                context.read<DoctorBloc>().add(
                                  FilterAppointmentsByDateRequested(
                                    startDate: startDate,
                                    endDate: endDate,
                                  ),
                                );
                              },
                            ),

                            // Appointments List
                            Expanded(
                              child: state.hasAppointments
                                  ? ListView.builder(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: state.filteredAppointments.length,
                                      itemBuilder: (context, index) {
                                        final appointment = state.filteredAppointments[index];
                                        return AppointmentCard(
                                          appointment: appointment,
                                        );
                                      },
                                    )
                                  : _buildEmptyState(context),
                            ),
                          ],
                        );
                      }

                      return _buildEmptyState(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateAppointment(context),
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Cita'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay citas programadas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega una nueva cita para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateAppointment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAppointmentPage(doctorId: widget.doctor.id),
      ),
    );
  }
}