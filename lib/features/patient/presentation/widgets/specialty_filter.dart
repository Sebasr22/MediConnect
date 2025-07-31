import 'package:flutter/material.dart';

class SpecialtyFilter extends StatelessWidget {
  final List<String> specialties;
  final ValueChanged<String?> onSpecialtySelected;

  const SpecialtyFilter({
    super.key,
    required this.specialties,
    required this.onSpecialtySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: specialties.length + 1, // +1 for "Todos" option
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChip(
              label: 'Todos',
              isSelected: false, // You can manage selection state
              onTap: () => onSpecialtySelected(null),
            );
          }

          final specialty = specialties[index - 1];
          return _FilterChip(
            label: specialty,
            isSelected: false, // You can manage selection state
            onTap: () => onSpecialtySelected(specialty),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.blue.shade50,
        selectedColor: Colors.blue.shade600,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? Colors.blue.shade600 : Colors.blue.shade200,
        ),
      ),
    );
  }
}