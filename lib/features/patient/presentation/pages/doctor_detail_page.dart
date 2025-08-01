import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/doctor_entity.dart';
import '../widgets/chat_modal.dart';
import '../bloc/patient_bloc.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> with TickerProviderStateMixin {
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _favoriteScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.elasticOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PatientBloc>().add(LoadFavoritesRequested());
      }
    });
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    _favoriteAnimationController.forward().then((_) {
      _favoriteAnimationController.reverse();
    });
    
    context.read<PatientBloc>().add(ToggleFavoriteRequested(widget.doctor.id.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.9),
                _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.7),
                Colors.white,
              ],
              stops: const [0.0, 0.4, 0.8],
            ),
          ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Perfil Médico',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        bool isFavorite = false;
                        if (state is DoctorsLoaded) {
                          isFavorite = state.isDoctorFavorite(widget.doctor.id.toString());
                        }
                        
                        return AnimatedBuilder(
                          animation: _favoriteScaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _favoriteScaleAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isFavorite 
                                      ? Colors.red.shade500.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isFavorite
                                      ? Border.all(color: Colors.red.shade300, width: 1)
                                      : null,
                                ),
                                child: IconButton(
                                  onPressed: _toggleFavorite,
                                  icon: Icon(
                                    isFavorite 
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite ? Colors.red.shade400 : Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              Container(
                margin: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getSpecialtyIcon(widget.doctor.specialty),
                            size: 70,
                            color: _getSpecialtyColor(widget.doctor.specialty),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.shade300.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        if (widget.doctor.rating >= 4.5)
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber.shade400, Colors.amber.shade600],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.shade300.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'TOP',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Dr. ${widget.doctor.name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSpecialtyIcon(widget.doctor.specialty),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.doctor.specialty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Details Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, -5),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          context,
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber.shade600,
                          title: 'Calificación',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ...List.generate(5, (index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 2),
                                      child: Icon(
                                        index < widget.doctor.rating.floor()
                                            ? Icons.star_rounded
                                            : index < widget.doctor.rating
                                                ? Icons.star_half_rounded
                                                : Icons.star_border_rounded,
                                        color: index < widget.doctor.rating.floor()
                                            ? Colors.amber.shade500
                                            : index < widget.doctor.rating
                                                ? Colors.amber.shade500
                                                : Colors.grey.shade300,
                                        size: 20,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade100,
                                      Colors.amber.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${widget.doctor.rating.toStringAsFixed(1)}/5.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade800,
                                    fontSize: 14,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Email Section
                        _buildInfoSection(
                          context,
                          icon: Icons.email_rounded,
                          iconColor: Colors.blue.shade600,
                          title: 'Email',
                          content: Text(
                            widget.doctor.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),

                        // Phone Section
                        _buildInfoSection(
                          context,
                          icon: Icons.phone_rounded,
                          iconColor: Colors.green.shade600,
                          title: 'Teléfono',
                          content: Text(
                            widget.doctor.phone,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),


                        const SizedBox(height: 32),

                        // Chat Button premium
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                _getSpecialtyColor(widget.doctor.specialty),
                                _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _getSpecialtyColor(widget.doctor.specialty).withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showChatModal(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Iniciar Chat',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            iconColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  iconColor.withValues(alpha: 0.1),
                  iconColor.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                content,
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatModal(doctor: widget.doctor),
    );
  }

  Color _getSpecialtyColor(String specialty) {
    final normalized = _normalizeSpecialtyString(specialty);
    if (normalized.contains('cardiolog')) {
      return Colors.red.shade600;
    } else if (normalized.contains('dermatolog')) {
      return Colors.pink.shade500;
    } else if (normalized.contains('neurolog')) {
      return Colors.purple.shade600;
    } else if (normalized.contains('pediatr')) {
      return Colors.orange.shade500;
    } else if (normalized.contains('oftalmo') || normalized.contains('oculist')) {
      return Colors.cyan.shade600;
    } else if (normalized.contains('traumatolog') || normalized.contains('ortoped')) {
      return Colors.brown.shade600;
    } else if (normalized.contains('psiquiat') || normalized.contains('psicolog')) {
      return Colors.indigo.shade600;
    } else if (normalized.contains('ginecolog') || normalized.contains('obstetr')) {
      return Colors.teal.shade600;
    } else if (normalized.contains('general') || normalized.contains('medic') || normalized.contains('intern')) {
      return Colors.blue.shade600;
    } else if (normalized.contains('anestesi')) {
      return Colors.deepPurple.shade600;
    } else if (normalized.contains('radio') || normalized.contains('imagen')) {
      return Colors.green.shade600;
    } else if (normalized.contains('patolog')) {
      return Colors.lime.shade700;
    } else if (normalized.contains('urolog')) {
      return Colors.lightBlue.shade600;
    } else if (normalized.contains('oncolog') || normalized.contains('cancer')) {
      return Colors.deepOrange.shade600;
    } else {
      // Fallback con color basado en el hash del string para consistencia
      final hash = specialty.hashCode;
      final colors = [
        Colors.blue.shade600,
        Colors.green.shade600,
        Colors.purple.shade600,
        Colors.orange.shade600,
        Colors.teal.shade600,
        Colors.indigo.shade600,
      ];
      return colors[hash.abs() % colors.length];
    }
  }
  
  String _normalizeSpecialtyString(String input) {
    return input
        .toLowerCase()
        .trim()
        // Remover acentos
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        // Remover caracteres especiales y espacios extra
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  IconData _getSpecialtyIcon(String specialty) {
    final normalized = _normalizeSpecialtyString(specialty);
    
    if (normalized.contains('cardiolog')) {
      return Icons.favorite;
    } else if (normalized.contains('dermatolog')) {
      return Icons.face;
    } else if (normalized.contains('neurolog')) {
      return Icons.psychology;
    } else if (normalized.contains('pediatr')) {
      return Icons.child_care;
    } else if (normalized.contains('oftalmo') || normalized.contains('oculist')) {
      return Icons.visibility;
    } else if (normalized.contains('traumatolog') || normalized.contains('ortoped')) {
      return Icons.healing;
    } else if (normalized.contains('psiquiat') || normalized.contains('psicolog')) {
      return Icons.psychology_alt;
    } else if (normalized.contains('ginecolog') || normalized.contains('obstetr')) {
      return Icons.woman;
    } else if (normalized.contains('general') || normalized.contains('medic') || normalized.contains('intern')) {
      return Icons.local_hospital;
    } else if (normalized.contains('anestesi')) {
      return Icons.airline_seat_recline_extra;
    } else if (normalized.contains('radio') || normalized.contains('imagen')) {
      return Icons.medical_information;
    } else if (normalized.contains('patolog')) {
      return Icons.biotech;
    } else if (normalized.contains('urolog')) {
      return Icons.water_drop;
    } else if (normalized.contains('oncolog') || normalized.contains('cancer')) {
      return Icons.health_and_safety;
    } else {
      return Icons.medical_services;
    }
  }
}