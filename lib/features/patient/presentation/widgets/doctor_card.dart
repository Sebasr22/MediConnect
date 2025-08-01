import 'package:flutter/material.dart';

import '../../../auth/domain/entities/doctor_entity.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final bool isFavorite;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColorBySpecialty(doctor.specialty);
    final isHighRated = doctor.rating >= 4.5;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shadowColor: avatarColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar moderno con variación por especialidad
                  Stack(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              avatarColor.withValues(alpha: 0.8),
                              avatarColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: avatarColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconBySpecialty(doctor.specialty),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      // Badge de disponibilidad
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      // Badge de favorito
                      if (isFavorite)
                        Positioned(
                          left: -2,
                          top: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red.shade400, Colors.red.shade600],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.shade300.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Doctor Info mejorada
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctor.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isHighRated)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade700,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'TOP',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: avatarColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doctor.specialty,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: avatarColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Rating estrella
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber.shade600,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    doctor.rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Botones de acción rápida
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                children: [
                                  _buildQuickActionButton(
                                    Icons.email_outlined,
                                    Colors.blue.shade600,
                                    'Email',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildQuickActionButton(
                                    Icons.phone_outlined,
                                    Colors.green.shade600,
                                    'Llamar',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon moderno
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey.shade600,
                      size: 16,
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

  Color _getAvatarColorBySpecialty(String specialty) {
    final specialtyLower = specialty.toLowerCase();
    
    if (specialtyLower.contains('cardio')) {
      return Colors.red.shade600;
    } else if (specialtyLower.contains('pediatr')) {
      return Colors.green.shade600;
    } else if (specialtyLower.contains('neurol')) {
      return Colors.purple.shade600;
    } else if (specialtyLower.contains('psiq')) {
      return Colors.indigo.shade600;
    } else if (specialtyLower.contains('general') || specialtyLower.contains('medicina')) {
      return Colors.blue.shade600;
    } else if (specialtyLower.contains('dermato')) {
      return Colors.orange.shade600;
    } else if (specialtyLower.contains('gineco')) {
      return Colors.pink.shade600;
    } else {
      return Colors.teal.shade600;
    }
  }

  IconData _getIconBySpecialty(String specialty) {
    final specialtyLower = specialty.toLowerCase();
    
    if (specialtyLower.contains('cardio')) {
      return Icons.favorite_outlined;
    } else if (specialtyLower.contains('pediatr')) {
      return Icons.child_care_outlined;
    } else if (specialtyLower.contains('neurol')) {
      return Icons.psychology_outlined;
    } else if (specialtyLower.contains('psiq')) {
      return Icons.psychology_outlined;
    } else if (specialtyLower.contains('general') || specialtyLower.contains('medicina')) {
      return Icons.local_hospital_outlined;
    } else if (specialtyLower.contains('dermato')) {
      return Icons.face_outlined;
    } else if (specialtyLower.contains('gineco')) {
      return Icons.pregnant_woman_outlined;
    } else {
      return Icons.medical_services_outlined;
    }
  }

  Widget _buildQuickActionButton(IconData icon, Color color, String tooltip) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 14,
      ),
    );
  }
}