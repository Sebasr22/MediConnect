import 'package:flutter/material.dart';

class ModernDateField extends StatefulWidget {
  final DateTime? selectedDate;
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(DateTime?)? validator;
  final Function(DateTime?) onDateSelected;
  final Color? focusColor;

  const ModernDateField({
    super.key,
    required this.selectedDate,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    required this.onDateSelected,
    this.focusColor,
  });

  @override
  State<ModernDateField> createState() => _ModernDateFieldState();
}

class _ModernDateFieldState extends State<ModernDateField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: widget.focusColor ?? Colors.blue.shade600,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    setState(() {
      _isFocused = true;
    });
    _animationController.forward();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate ?? DateTime.now().subtract(
        const Duration(days: 365 * 25),
      ),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 100),
      ),
      lastDate: DateTime.now().subtract(
        const Duration(days: 365 * 16),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.focusColor ?? Colors.blue.shade800,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    setState(() {
      _isFocused = false;
    });
    _animationController.reverse();

    if (picked != null && picked != widget.selectedDate) {
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFocused 
                      ? (widget.focusColor ?? Colors.blue.shade600).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: _isFocused ? 20 : 10,
                  offset: const Offset(0, 5),
                  spreadRadius: _isFocused ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: _colorAnimation.value ?? Colors.grey.shade300,
                width: _isFocused ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 12, right: 20),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _isFocused 
                          ? widget.focusColor ?? Colors.blue.shade600
                          : Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                
                // Date selector
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      top: 4,
                    ),
                    child: Row(
                      children: [
                        if (widget.prefixIcon != null) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              widget.prefixIcon,
                              color: _isFocused 
                                  ? widget.focusColor ?? Colors.blue.shade600
                                  : Colors.grey.shade500,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            widget.selectedDate != null
                                ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                                : widget.hintText,
                            style: TextStyle(
                              color: widget.selectedDate != null
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: widget.selectedDate != null
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}