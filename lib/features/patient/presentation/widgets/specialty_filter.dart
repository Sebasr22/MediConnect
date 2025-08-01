import 'package:flutter/material.dart';

class SpecialtyFilter extends StatefulWidget {
  final List<String> specialties;
  final ValueChanged<String?> onSpecialtySelected;

  const SpecialtyFilter({
    super.key,
    required this.specialties,
    required this.onSpecialtySelected,
  });

  @override
  State<SpecialtyFilter> createState() => _SpecialtyFilterState();
}

class _SpecialtyFilterState extends State<SpecialtyFilter> {
  String? selectedSpecialty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.specialties.length + 3, // +3 for "Todos", "Populares", and "Favoritos"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChip(
              label: 'Todos',
              count: widget.specialties.length,
              isSelected: selectedSpecialty == null,
              onTap: () {
                setState(() {
                  selectedSpecialty = null;
                });
                widget.onSpecialtySelected(null);
              },
            );
          } else if (index == 1) {
            return _FilterChip(
              label: '⭐ Populares',
              isSelected: selectedSpecialty == 'populares',
              onTap: () {
                setState(() {
                  selectedSpecialty = 'populares';
                });
                widget.onSpecialtySelected('populares');
              },
            );
          } else if (index == 2) {
            return _FilterChip(
              label: '💖 Favoritos',
              isSelected: selectedSpecialty == 'favoritos',
              onTap: () {
                setState(() {
                  selectedSpecialty = 'favoritos';
                });
                widget.onSpecialtySelected('favoritos');
              },
            );
          }

          final specialty = widget.specialties[index - 3];
          return _FilterChip(
            label: specialty,
            isSelected: selectedSpecialty == specialty,
            onTap: () {
              setState(() {
                selectedSpecialty = specialty;
              });
              widget.onSpecialtySelected(specialty);
            },
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
  final int? count;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade700,
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.blue.shade50.withValues(alpha: 0.3),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.blue.shade600
                : Colors.blue.shade200.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade300.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.shade200.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.blue.shade800,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}