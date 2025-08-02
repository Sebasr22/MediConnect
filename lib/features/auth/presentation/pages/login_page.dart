import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/injection.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/modern_text_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/pulse_icon.dart';
import '../widgets/animated_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              // Navigate based on user type
              if (state.isDoctor) {
                context.go(AppRouter.doctorDashboard);
              } else if (state.isPatient) {
                context.go(AppRouter.patientDashboard);
              }
            }
          },
          child: AnimatedBackground(
            gradientColors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.cyan.shade400,
              Colors.blue.shade500,
            ],
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = constraints.maxHeight;
                  final isVerySmallScreen = screenHeight < 600;
                  final isSmallScreen = screenHeight < 700;
                  
                  return Container(
                    constraints: BoxConstraints(
                      minHeight: screenHeight,
                      maxHeight: screenHeight,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: isVerySmallScreen ? 8.0 : (isSmallScreen ? 16.0 : 32.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Hero Section
                                _buildHeroSection(context, isSmallScreen, isVerySmallScreen),
                                SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 24 : 48)),
                                
                                // Glass Card
                                Flexible(child: _buildGlassCard(context, isSmallScreen, isVerySmallScreen)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Column(
      children: [
        // Animated Logo
        PulseIcon(
          icon: Icons.medical_services_rounded,
          size: isVerySmallScreen ? 45 : (isSmallScreen ? 60 : 80),
          color: Colors.blue.shade700,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
        ),
        SizedBox(height: isVerySmallScreen ? 12 : (isSmallScreen ? 20 : 32)),
        
        // Title with gradient text
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'MediConnect',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: isVerySmallScreen ? 28 : (isSmallScreen ? 32 : 42),
              letterSpacing: -1,
            ),
          ),
        ),
        SizedBox(height: isVerySmallScreen ? 4 : (isSmallScreen ? 8 : 12)),
        
        // Subtitle (hidden on very small screens)
        if (!isVerySmallScreen) ...[
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24, 
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              'Conectando pacientes y doctores',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGlassCard(BuildContext context, bool isSmallScreen, bool isVerySmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                Colors.white.withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome text
                Text(
                  '¡Bienvenido de vuelta!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Text(
                  'Inicia sesión para continuar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 24 : 40),

                // Email Field
                ModernTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hintText: 'tu@email.com',
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  focusColor: Colors.blue.shade600,
                ),
                SizedBox(height: isSmallScreen ? 12 : 20),

                // Password Field
                ModernTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: 'Tu contraseña segura',
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                  obscureText: true,
                  focusColor: Colors.blue.shade600,
                ),
                SizedBox(height: isSmallScreen ? 20 : 32),

                // Login Button
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade700,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade300.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: 'Iniciar Sesión',
                        isLoading: state is AuthLoading,
                        backgroundColor: Colors.transparent,
                        height: 56,
                        borderRadius: BorderRadius.circular(16),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),

                // Register Link
                Container(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      context.push(AppRouter.register);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: '¿No tienes cuenta? ',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
}
