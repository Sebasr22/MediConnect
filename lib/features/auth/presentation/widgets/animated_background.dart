import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final List<Color> gradientColors;
  final Widget child;

  const AnimatedBackground({
    super.key,
    required this.gradientColors,
    required this.child,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _particles = List.generate(15, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
          stops: const [0.0, 0.4, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _controller.value),
                size: Size.infinite,
              );
            },
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double opacity;
  late IconData icon;

  Particle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 20 + 10;
    speed = random.nextDouble() * 0.02 + 0.005;
    opacity = random.nextDouble() * 0.3 + 0.1;
    
    // Medical-themed icons
    final icons = [
      Icons.favorite_outline,
      Icons.medical_services_outlined,
      Icons.health_and_safety_outlined,
      Icons.local_hospital_outlined,
      Icons.healing_outlined,
      Icons.medication_outlined,
    ];
    icon = icons[random.nextInt(icons.length)];
    
    // Soft medical colors
    final colors = [
      Colors.white,
      Colors.cyan.shade100,
      Colors.teal.shade100,
      Colors.blue.shade100,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update() {
    y -= speed;
    if (y < -0.1) {
      y = 1.1;
      x = math.Random().nextDouble();
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw subtle glow
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(position, particle.size + 5, glowPaint);

      // Draw particle as a circle (simplified icon representation)
      canvas.drawCircle(position, particle.size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}