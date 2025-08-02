import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/injection.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/doctor_bloc.dart';
import '../widgets/appointment_card.dart';
import '../widgets/date_filter.dart';
import 'create_appointment_page.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  User? _doctor;
  bool _isLoadingUser = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final storageService = getIt<StorageService>();
      final userData = await storageService.getUserDataSecure();
      
      if (userData != null) {
        try {
          final doctor = UserModel.fromJson(userData);
          setState(() {
            _doctor = doctor;
            _isLoadingUser = false;
          });
        } catch (parseError) {
          setState(() {
            _isLoadingUser = false;
            _hasError = true;
            _errorMessage = 'Error al cargar datos del usuario: $parseError';
          });
        }
      } else {
        setState(() {
          _isLoadingUser = false;
          _hasError = true;
          _errorMessage = 'No se encontraron datos de usuario. Inicia sesión nuevamente.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
        _hasError = true;
        _errorMessage = 'Error cargando datos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoadingUser) {
      return Scaffold(
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Error state
    if (_hasError || _doctor == null) {
      return Scaffold(
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Error de Autenticación',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage ?? 'No se pudieron cargar los datos del usuario',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _goToLogin(),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Volver al Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _retryLoadUser(),
                    child: Text(
                      'Reintentar',
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => getIt<DoctorBloc>()
        ..add(GetAppointmentsRequested(_doctor!.id)),
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.teal.shade50.withValues(alpha: 0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade100.withValues(alpha: 0.5),
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
                                  Colors.teal.shade400,
                                  Colors.teal.shade700,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.shade200.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_services,
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
                                    color: Colors.teal.shade800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dr. ${_doctor!.name}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Botón de logout
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
                      BlocBuilder<DoctorBloc, DoctorState>(
                        builder: (context, state) {
                          if (state is AppointmentsLoaded) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.today_outlined,
                                    value: '${state.todayAppointments.length}',
                                    label: 'Hoy',
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.event_outlined,
                                    value: '${state.appointments.length}',
                                    label: 'Total',
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.schedule_outlined,
                                    value: '${state.upcomingAppointments.length}',
                                    label: 'Próximas',
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.today_outlined,
                                  value: '0',
                                  label: 'Hoy',
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.event_outlined,
                                  value: '0',
                                  label: 'Total',
                                  color: Colors.teal.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.schedule_outlined,
                                  value: '0',
                                  label: 'Próximas',
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          );
                        },
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
                                    GetAppointmentsRequested(_doctor!.id),
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
        floatingActionButton: Builder(
          builder: (builderContext) => FloatingActionButton.extended(
            onPressed: () => _navigateToCreateAppointment(builderContext),
            backgroundColor: Colors.teal.shade600,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cita'),
          ),
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
    // Capture the DoctorBloc reference from the original context
    final doctorBloc = context.read<DoctorBloc>();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: doctorBloc,
          child: CreateAppointmentPage(doctorId: _doctor!.id),
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

  void _goToLogin() {
    context.go(AppRouter.login);
  }

  void _retryLoadUser() {
    setState(() {
      _isLoadingUser = true;
      _hasError = false;
      _errorMessage = null;
      _doctor = null;
    });
    _loadUserData();
  }
}