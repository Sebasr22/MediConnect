import 'package:flutter/material.dart';

class PulseIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Color? backgroundColor;

  const PulseIcon({
    super.key,
    required this.icon,
    this.size = 60,
    required this.color,
    this.backgroundColor,
  });

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation (heartbeat effect)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Subtle rotation animation
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 0.1, // Subtle rotation
            child: Container(
              width: widget.size + 40,
              height: widget.size + 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.backgroundColor ?? Colors.white.withValues(alpha: 0.9),
                    widget.backgroundColor?.withValues(alpha: 0.7) ?? Colors.white.withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: widget.size,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}