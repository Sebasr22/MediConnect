import 'dart:async';
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

class _PatientDashboardState extends State<PatientDashboard> with WidgetsBindingObserver {
  final _searchController = TextEditingController();
  Timer? _searchTimer;
  PatientBloc? _patientBloc;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    // Registrar el observer para escuchar cambios de lifecycle
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remover el observer
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('🔄 App lifecycle cambió a: $state'); // Debug log
    
    if (state == AppLifecycleState.resumed && _hasLoadedData) {
      // Cuando la app vuelve a ser visible, recargar datos si ya habíamos cargado antes
      print('🔄 App resumed - recargando doctores'); // Debug log
      _reloadDoctors();
    }
  }

  void _reloadDoctors() {
    if (_patientBloc != null && mounted) {
      print('🔄 Recargando lista de doctores...'); // Debug log
      _patientBloc!.add(GetDoctorsRequested());
    }
  }

  void _onSearchChanged(String query) {
    // Cancelar el timer anterior si existe
    _searchTimer?.cancel();
    
    // Crear un nuevo timer con delay de 300ms
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      print('🔍 Ejecutando búsqueda para: "$query"'); // Debug log
      if (mounted && _patientBloc != null) {
        _patientBloc!.add(SearchDoctorsRequested(query));
      }
    });
  }

  void _onSearchPressed() {
    // Búsqueda inmediata al presionar el botón
    _searchTimer?.cancel();
    final query = _searchController.text;
    print('🔍 Búsqueda inmediata con botón: "$query"'); // Debug log
    if (_patientBloc != null) {
      _patientBloc!.add(SearchDoctorsRequested(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _patientBloc = getIt<PatientBloc>()..add(GetDoctorsRequested());
        return _patientBloc!;
      },
      child: BlocListener<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is DoctorsLoaded) {
            _hasLoadedData = true;
            print('✅ Datos cargados exitosamente - hasLoadedData = true'); // Debug log
          } else if (state is PatientError) {
            print('❌ Error detectado: ${state.message}'); // Debug log
          }
        },
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
                        onChanged: _onSearchChanged,
                        onSearchPressed: _onSearchPressed,
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
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 80,
                                  color: Colors.orange.shade400,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Conexión Perdida',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Parece que hubo un problema al cargar los doctores.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      print('🔄 Usuario presionó recargar manualmente'); // Debug log
                                      _reloadDoctors();
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text(
                                      'Recargar Doctores',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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