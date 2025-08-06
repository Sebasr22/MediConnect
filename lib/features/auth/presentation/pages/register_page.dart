import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

import '../../../../core/utils/injection.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/notification_service.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_type_selector.dart';
import '../widgets/modern_date_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _ratingController = TextEditingController();

  UserType _selectedUserType = UserType.patient;
  DateTime? _selectedBirthdate;

  // Specialties list for dropdown
  final List<String> _specialties = [
    'Cardiología',
    'Dermatología',
    'Endocrinología',
    'Gastroenterología',
    'Ginecología',
    'Neurología',
    'Oftalmología',
    'Oncología',
    'Pediatría',
    'Psiquiatría',
    'Traumatología',
    'Urología',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _specialtyController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400 || screenHeight < 600;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              NotificationService.showError(context, state.message);
            } else if (state is AuthAuthenticated) {
              NotificationService.showSuccess(context, '¡Registro exitoso!');
              // Navigate to appropriate dashboard
              if (state.isDoctor) {
                context.go(AppRouter.doctorDashboard);
              } else if (state.isPatient) {
                context.go(AppRouter.patientDashboard);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.cyan.shade500,
                  Colors.blue.shade400,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - MediaQuery.of(context).padding.top - keyboardHeight - (isSmallScreen ? 32 : 48),
                  ),
                  child: Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          // Header
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person_add,
                                      size: isSmallScreen ? 48 : 60,
                                      color: Colors.blue.shade800,
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 12),
                                    Text(
                                      'Crear Cuenta',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                            fontSize: isSmallScreen ? 20 : null,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Únete a MediConnect',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontSize: isSmallScreen ? 13 : null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 48,
                              ), // Balance the back button
                            ],
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 32),

                          // User Type Selector
                          UserTypeSelector(
                            selectedType: _selectedUserType,
                            onChanged: (type) {
                              setState(() {
                                _selectedUserType = type;
                                // Clear specialty and rating when switching to patient
                                if (type == UserType.patient) {
                                  _specialtyController.clear();
                                  _ratingController.clear();
                                }
                              });
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 16 : 24),

                          // Common Fields
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre Completo',
                            hintText: 'Juan Pérez',
                            prefixIcon: Icons.person_outline,
                            validator: Validators.validateName,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hintText: 'juan@example.com',
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            hintText: '+584141234567',
                            prefixIcon: Icons.phone_outlined,
                            validator: Validators.validatePhone,
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Conditional Fields
                          if (_selectedUserType == UserType.patient)
                            _buildPatientFields()
                          else
                            _buildDoctorFields(),

                          SizedBox(height: isSmallScreen ? 12 : 16),

                          // Password Fields
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            hintText: 'Mínimo 8 caracteres',
                            prefixIcon: Icons.lock_outline,
                            validator: Validators.validatePassword,
                            obscureText: true,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),

                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmar Contraseña',
                            hintText: 'Repite tu contraseña',
                            prefixIcon: Icons.lock_outline,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                            obscureText: true,
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 32),

                          // Register Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: 'Crear Cuenta',
                                isLoading: state is AuthLoading,
                                backgroundColor: Colors.blue.shade800,
                                onPressed: () => _submitForm(context),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),  // Cierra BlocListener
      ),  // Cierra BlocProvider
    );    // Cierra Scaffold
  }

  Widget _buildPatientFields() {
    return Column(
      children: [
        // Birthdate Field
        ModernDateField(
          selectedDate: _selectedBirthdate,
          label: 'Fecha de Nacimiento',
          hintText: 'Selecciona tu fecha de nacimiento',
          prefixIcon: Icons.calendar_today,
          focusColor: Colors.blue.shade600,
          onDateSelected: (date) {
            setState(() {
              _selectedBirthdate = date;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDoctorFields() {
    return Column(
      children: [
        // Specialty Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Especialidad',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                return DropdownButtonFormField<String>(
                  value: _specialtyController.text.isEmpty
                      ? null
                      : _specialtyController.text,
                  decoration: InputDecoration(
                    hintText: 'Selecciona tu especialidad',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(
                      Icons.medical_services,
                      color: Colors.grey.shade600,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                    ),
                  ),
                  isExpanded: true,
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Flexible(
                        child: Text(
                          specialty,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _specialtyController.text = value ?? '';
                    });
                  },
                  validator: (value) =>
                      value == null ? 'La especialidad es requerida' : null,
                  selectedItemBuilder: (BuildContext context) {
                    return _specialties.map<Widget>((String specialty) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 80,
                        ),
                        child: Text(
                          specialty,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList();
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Rating Field
        CustomTextField(
          controller: _ratingController,
          label: 'Calificación (1-5)',
          hintText: '4.5',
          prefixIcon: Icons.star_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La calificación es requerida';
            }
            final rating = double.tryParse(value);
            if (rating == null || rating < 1 || rating > 5) {
              return 'Ingresa una calificación entre 1 y 5';
            }
            return null;
          },
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
      ],
    );
  }


  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserType == UserType.patient) {
        if (_selectedBirthdate == null) {
          NotificationService.showError(context, 'Por favor selecciona tu fecha de nacimiento');
          return;
        }

        context.read<AuthBloc>().add(
          RegisterPatientRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            birthdate: _selectedBirthdate!,
          ),
        );
      } else {
        context.read<AuthBloc>().add(
          RegisterDoctorRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            specialty: _specialtyController.text,
            rating: double.parse(_ratingController.text),
          ),
        );
      }
    }
  }
}
