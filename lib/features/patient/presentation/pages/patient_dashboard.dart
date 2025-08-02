import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/injection.dart';
import '../../../../core/navigation/app_router.dart';
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
    
    if (state == AppLifecycleState.resumed && _hasLoadedData) {
      // Cuando la app vuelve a ser visible, recargar datos si ya habíamos cargado antes
      _reloadDoctors();
    }
  }

  void _reloadDoctors() {
    if (_patientBloc != null && mounted) {
      _patientBloc!.add(GetDoctorsRequested());
    }
  }

  void _onSearchChanged(String query) {
    // Cancelar el timer anterior si existe
    _searchTimer?.cancel();
    
    // Crear un nuevo timer con delay de 300ms
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted && _patientBloc != null) {
        _patientBloc!.add(SearchDoctorsRequested(query));
      }
    });
  }

  void _onSearchPressed() {
    // Búsqueda inmediata al presionar el botón
    _searchTimer?.cancel();
    final query = _searchController.text;
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.blue.shade50.withValues(alpha: 0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade100.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar personalizado
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.blue.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.shade200.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue.shade800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Encuentra tu doctor ideal hoy',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botones de acción modernos
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () {
                                _showLogoutDialog(context);
                              },
                              icon: Icon(
                                Icons.logout_rounded,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                              tooltip: 'Cerrar sesión',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Stats row premium
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.local_hospital_outlined,
                              value: '23',
                              label: 'Doctores',
                              color: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.star_outline_rounded,
                              value: '4.8',
                              label: 'Rating',
                              color: Colors.amber.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.schedule_outlined,
                              value: '24/7',
                              label: 'Disponible',
                              color: Colors.green.shade600,
                            ),
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
                                          isFavorite: state.isDoctorFavorite(doctor.id.toString()),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '¡Buenos días!';
    } else if (hour < 18) {
      return '¡Buenas tardes!';
    } else {
      return '¡Buenas noches!';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade200,
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 60,
                color: Colors.blue.shade600,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No se encontraron doctores',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Intenta con una búsqueda diferente o\nexplora otras especialidades',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Prueba buscar por "Cardiología" o "General"',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDoctorDetail(BuildContext context, Doctor doctor) async {
    final patientBloc = context.read<PatientBloc>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: patientBloc,
          child: DoctorDetailPage(doctor: doctor),
        ),
      ),
    );
    
    // Recargar favoritos cuando regresemos del detalle
    if (mounted) {
      patientBloc.add(LoadFavoritesRequested());
    }
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

}