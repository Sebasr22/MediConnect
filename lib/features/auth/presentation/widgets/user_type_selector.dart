import 'package:flutter/material.dart';

enum UserType { patient, doctor }

class UserTypeSelector extends StatelessWidget {
  final UserType selectedType;
  final ValueChanged<UserType> onChanged;

  const UserTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Usuario',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _UserTypeCard(
                type: UserType.patient,
                selectedType: selectedType,
                onTap: () => onChanged(UserType.patient),
                icon: Icons.person,
                title: 'Paciente',
                subtitle: 'Buscar doctores y agendar citas',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _UserTypeCard(
                type: UserType.doctor,
                selectedType: selectedType,
                onTap: () => onChanged(UserType.doctor),
                icon: Icons.medical_services,
                title: 'Doctor',
                subtitle: 'Gestionar citas y pacientes',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final UserType type;
  final UserType selectedType;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  const _UserTypeCard({
    required this.type,
    required this.selectedType,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  bool get isSelected => type == selectedType;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
