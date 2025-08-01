import 'package:flutter/material.dart';

class AppointmentStats extends StatelessWidget {
  final int totalAppointments;
  final int todayAppointments;
  final int upcomingAppointments;

  const AppointmentStats({
    super.key,
    required this.totalAppointments,
    required this.todayAppointments,
    required this.upcomingAppointments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.event_note,
              iconColor: Colors.blue.shade600,
              title: 'Total',
              value: totalAppointments.toString(),
              backgroundColor: Colors.blue.shade50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.today,
              iconColor: Colors.orange.shade600,
              title: 'Hoy',
              value: todayAppointments.toString(),
              backgroundColor: Colors.orange.shade50,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.schedule,
              iconColor: Colors.green.shade600,
              title: 'Próximas',
              value: upcomingAppointments.toString(),
              backgroundColor: Colors.green.shade50,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Color backgroundColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}