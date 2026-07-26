import 'dart:math' as math;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF211A46),
                  Color(0xFF49366F),
                  Color(0xFF8A5F86),
                ],
                stops: [0, 0.58, 1],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _StarFieldPainter(_animationController.value),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 600;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _GlowingFlower(
                            animation: _animationController,
                            size: compact ? 104 : 132,
                          ),
                          SizedBox(height: compact ? 26 : 38),
                          Text(
                            '루미아의 별정원',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFFFF8E8),
                              fontSize: compact ? 34 : 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.2,
                              height: 1.15,
                              shadows: const [
                                Shadow(
                                  color: Color(0x99745A9D),
                                  blurRadius: 18,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '마음속 작은 용기가 별이 되는 곳',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFFFE8F2).withValues(
                                alpha: 0.9,
                              ),
                              fontSize: compact ? 15 : 17,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: compact ? 36 : 58),
                          const Semantics(
                            label: '별정원을 불러오는 중',
                            child: SizedBox.square(
                              dimension: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFFFFD8A8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowingFlower extends StatelessWidget {
  const _GlowingFlower({required this.animation, required this.size});

  final Animation<double> animation;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final glow = 22 + (animation.value * 16);
        return Transform.scale(
          scale: 0.97 + (animation.value * 0.03),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF7CF), Color(0xFFF4B8CD)],
              ),
              border: Border.all(
                color: const Color(0xFFFFFAE8).withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFCEBE).withValues(alpha: 0.48),
                  blurRadius: glow,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.local_florist_rounded,
              size: size * 0.55,
              color: const Color(0xFF8658A0),
              semanticLabel: '빛나는 꽃',
            ),
          ),
        );
      },
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter(this.animationValue);

  final double animationValue;

  static const _stars = <Offset>[
    Offset(0.08, 0.13),
    Offset(0.18, 0.31),
    Offset(0.29, 0.09),
    Offset(0.42, 0.22),
    Offset(0.57, 0.08),
    Offset(0.69, 0.28),
    Offset(0.83, 0.12),
    Offset(0.92, 0.37),
    Offset(0.12, 0.62),
    Offset(0.26, 0.79),
    Offset(0.73, 0.72),
    Offset(0.88, 0.84),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < _stars.length; index++) {
      final star = _stars[index];
      final wave = (math.sin((animationValue * math.pi) + index) + 1) / 2;
      final radius = 1.2 + (wave * 1.8);
      final paint = Paint()
        ..color = const Color(0xFFFFF2C7).withValues(alpha: 0.4 + wave * 0.5);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
