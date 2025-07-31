import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/app_router.dart';

import '../../../../core/utils/injection.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/user_type_selector.dart';

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
    return Scaffold(
      body: BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Registro exitoso!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate to appropriate dashboard
              if (state.isDoctor) {
                context.go(AppRouter.doctorDashboard, extra: state.user);
              } else if (state.isPatient) {
                context.go(AppRouter.patientDashboard, extra: state.user);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade800,
                  Colors.green.shade600,
                  Colors.teal.shade400,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
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
                                      size: 60,
                                      color: Colors.green.shade800,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Crear Cuenta',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
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
                          const SizedBox(height: 32),

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
                          const SizedBox(height: 24),

                          // Common Fields
                          CustomTextField(
                            controller: _nameController,
                            label: 'Nombre Completo',
                            hintText: 'Juan Pérez',
                            prefixIcon: Icons.person_outline,
                            validator: Validators.validateName,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hintText: 'juan@example.com',
                            prefixIcon: Icons.email_outlined,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            controller: _phoneController,
                            label: 'Teléfono',
                            hintText: '+584141234567',
                            prefixIcon: Icons.phone_outlined,
                            validator: Validators.validatePhone,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          // Conditional Fields
                          if (_selectedUserType == UserType.patient)
                            _buildPatientFields()
                          else
                            _buildDoctorFields(),

                          const SizedBox(height: 16),

                          // Password Fields
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Contraseña',
                            hintText: 'Mínimo 8 caracteres',
                            prefixIcon: Icons.lock_outline,
                            validator: Validators.validatePassword,
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),

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
                          const SizedBox(height: 32),

                          // Register Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return CustomButton(
                                text: 'Crear Cuenta',
                                isLoading: state is AuthLoading,
                                backgroundColor: Colors.green.shade800,
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
      ),
    );
  }

  Widget _buildPatientFields() {
    return Column(
      children: [
        // Birthdate Field
        GestureDetector(
          onTap: () => _selectBirthdate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedBirthdate != null
                        ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                        : 'Fecha de Nacimiento',
                    style: TextStyle(
                      color: _selectedBirthdate != null
                          ? Colors.black
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            DropdownButtonFormField<String>(
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
              items: _specialties.map((specialty) {
                return DropdownMenuItem(
                  value: specialty,
                  child: Text(specialty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _specialtyController.text = value ?? '';
                });
              },
              validator: (value) =>
                  value == null ? 'La especialidad es requerida' : null,
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

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 25),
      ), // 25 years ago
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 100),
      ), // 100 years ago
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 16),
      ), // 16 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserType == UserType.patient) {
        if (_selectedBirthdate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor selecciona tu fecha de nacimiento'),
              backgroundColor: Colors.red,
            ),
          );
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
