import 'package:flutter/material.dart';

enum UserType { patient, doctor }

class ModernUserTypeCard extends StatefulWidget {
  final UserType userType;
  final bool isSelected;
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const ModernUserTypeCard({
    super.key,
    required this.userType,
    required this.isSelected,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<ModernUserTypeCard> createState() => _ModernUserTypeCardState();
}

class _ModernUserTypeCardState extends State<ModernUserTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(ModernUserTypeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isSelected
                        ? [
                            widget.primaryColor.withValues(alpha: 0.2),
                            widget.secondaryColor.withValues(alpha: 0.1),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.8),
                          ],
                  ),
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.primaryColor
                        : Colors.grey.shade300,
                    width: widget.isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isSelected
                          ? widget.primaryColor.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: widget.isSelected ? 20 : 10,
                      offset: const Offset(0, 8),
                      spreadRadius: widget.isSelected ? 2 : 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Icon container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.isSelected
                              ? [widget.primaryColor, widget.secondaryColor]
                              : [Colors.grey.shade200, Colors.grey.shade300],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isSelected
                                ? widget.primaryColor.withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: widget.isSelected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: widget.isSelected
                            ? widget.primaryColor
                            : Colors.grey.shade800,
                      ),
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected
                            ? widget.primaryColor.withValues(alpha: 0.8)
                            : Colors.grey.shade600,
                      ),
                      child: Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Selection indicator
                    if (widget.isSelected) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: widget.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Seleccionado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}