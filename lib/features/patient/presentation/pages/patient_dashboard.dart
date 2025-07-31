import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/injection.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../auth/domain/entities/doctor_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../widgets/doctor_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/specialty_filter.dart';
import 'doctor_detail_page.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PatientBloc>()..add(GetDoctorsRequested()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade50,
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
                        color: Colors.blue.shade100,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.blue.shade800,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola Paciente!',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                Text(
                                  'Encuentra el doctor perfecto para ti',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showClearDataDialog(context);
                                },
                                icon: Icon(
                                  Icons.delete_forever,
                                  color: Colors.red.shade600,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _showLogoutDialog(context);
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
                      const SizedBox(height: 20),
                      
                      // Search Bar
                      SearchBarWidget(
                        controller: _searchController,
                        onChanged: (query) {
                          context.read<PatientBloc>().add(SearchDoctorsRequested(query));
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, state) {
                      if (state is PatientLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state is PatientError) {
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
                                  context.read<PatientBloc>().add(GetDoctorsRequested());
                                },
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is DoctorsLoaded) {
                        return Column(
                          children: [
                            // Specialty Filter
                            SpecialtyFilter(
                              specialties: state.specialties,
                              onSpecialtySelected: (specialty) {
                                context.read<PatientBloc>().add(
                                  FilterDoctorsBySpecialtyRequested(specialty),
                                );
                              },
                            ),

                            // Doctors List
                            Expanded(
                              child: state.hasResults
                                  ? ListView.builder(
                                      padding: const EdgeInsets.all(20),
                                      itemCount: state.filteredDoctors.length,
                                      itemBuilder: (context, index) {
                                        final doctor = state.filteredDoctors[index];
                                        return DoctorCard(
                                          doctor: doctor,
                                          onTap: () => _navigateToDoctorDetail(context, doctor),
                                        );
                                      },
                                    )
                                  : _buildEmptyState(),
                            ),
                          ],
                        );
                      }

                      return _buildEmptyState();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron doctores',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con una búsqueda diferente',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDoctorDetail(BuildContext context, Doctor doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailPage(doctor: doctor),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                getIt<AuthBloc>().add(LogoutRequested());
                context.go(AppRouter.login);
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Limpiar Datos'),
          content: const Text('¿Limpiar TODOS los datos guardados? Esto te llevará al login.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  final storageService = getIt<StorageService>();
                  await storageService.clearAllUserData();
                  await storageService.clearSharedPreferences();
                  await storageService.clearSecureStorage();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                }
              },
              child: const Text('Limpiar Todo'),
            ),
          ],
        );
      },
    );
  }
}