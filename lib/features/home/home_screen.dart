import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../game/game_controller.dart';
import '../game/game_screen.dart';
import '../how_to_play/how_to_play_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _saffronBorder = Color(0x33FFFFFF);

  Future<void> _play(BuildContext context, WidgetRef ref) async {
    await ref.read(gameControllerProvider.notifier).startNewRound();
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0808),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0F0F),
              Color(0xFF0D0808),
              Color(0xFF0A0606),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -90,
              left: -70,
              child: _AmbientGlow(
                color: Color(0x55FF6F2C),
                size: 280,
              ),
            ),
            const Positioned(
              top: -20,
              right: -40,
              child: IgnorePointer(child: _DecorativePattern()),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: _saffronBorder, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.88, end: 1),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: const _SaffronClapboardBadge(),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'BOLLYWOOD GUESS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'GUESS THE BLOCKBUSTER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.saffron,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _SparkleDivider(),
                        const SizedBox(height: 18),
                        const Text(
                          'GUESS THE MOVIE.\nBEAT THE CLOCK.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                            height: 1.55,
                          ),
                        ),
                        const Spacer(flex: 3),
                        _HomeActionButton(
                          filled: true,
                          color: AppColors.saffron,
                          foreground: Colors.black,
                          icon: Icons.play_arrow_rounded,
                          label: 'PLAY GAME',
                          onPressed: () => _play(context, ref),
                        ),
                        const SizedBox(height: 14),
                        _HomeActionButton(
                          filled: false,
                          color: AppColors.magenta,
                          foreground: AppColors.magenta,
                          icon: Icons.settings_outlined,
                          label: 'SETTINGS',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _HomeActionButton(
                          filled: false,
                          color: AppColors.emerald,
                          foreground: AppColors.emerald,
                          icon: Icons.help_outline_rounded,
                          label: 'HOW TO PLAY',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HowToPlayScreen(),
                              ),
                            );
                          },
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 90, spreadRadius: 50),
        ],
      ),
    );
  }
}

class _SaffronClapboardBadge extends StatelessWidget {
  const _SaffronClapboardBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.38),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(painter: _ClapboardPainter()),
    );
  }
}

class _ClapboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final ringPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.saffronSoft,
          AppColors.saffron,
          Color(0xFFD45A20),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    final fillPaint = Paint()
      ..color = const Color(0xFF1A0F0F)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - 3.5, fillPaint);
    canvas.drawCircle(center, radius - 3.5, ringPaint);

    // Inner ring
    final innerRing = Paint()
      ..color = AppColors.saffronSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(center, radius * 0.62, innerRing);

    // Hub
    final hubPaint = Paint()
      ..shader = const RadialGradient(
        colors: [AppColors.saffronSoft, AppColors.saffron],
      ).createShader(Rect.fromCircle(center: center, radius: 10));
    canvas.drawCircle(center, 9, hubPaint);

    // Spokes (clapboard-inspired diagonal lines)
    final spokePaint = Paint()
      ..color = AppColors.saffron
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final inner = Offset(
        center.dx + math.cos(angle) * 16,
        center.dy + math.sin(angle) * 16,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius * 0.52),
        center.dy + math.sin(angle) * (radius * 0.52),
      );
      canvas.drawLine(inner, outer, spokePaint);
    }

    // Holes
    final holePaint = Paint()..color = const Color(0xFF0D0808);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + math.pi / 6;
      final hole = Offset(
        center.dx + math.cos(angle) * (radius * 0.36),
        center.dy + math.sin(angle) * (radius * 0.36),
      );
      canvas.drawCircle(hole, 6.5, holePaint);
      canvas.drawCircle(
        hole,
        6.5,
        Paint()
          ..color = AppColors.saffron.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkleDivider extends StatelessWidget {
  const _SparkleDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: CustomPaint(
        painter: _SparkleDividerPainter(),
        size: const Size(double.infinity, 18),
      ),
    );
  }
}

class _SparkleDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final mid = size.width / 2;
    final line = Paint()
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        colors: [
          AppColors.saffron.withValues(alpha: 0),
          AppColors.saffron.withValues(alpha: 0.9),
          AppColors.saffron.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(8, cy), Offset(mid - 16, cy), line);
    canvas.drawLine(Offset(mid + 16, cy), Offset(size.width - 8, cy), line);

    final sparkle = Paint()..color = AppColors.saffronSoft;
    _drawStar(canvas, Offset(mid, cy), 7.5, sparkle);
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -math.pi / 2 + i * math.pi / 2;
      final outer = Offset(c.dx + math.cos(angle) * r, c.dy + math.sin(angle) * r);
      final innerAngle = angle + math.pi / 4;
      final inner = Offset(
        c.dx + math.cos(innerAngle) * (r * 0.28),
        c.dy + math.sin(innerAngle) * (r * 0.28),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DecorativePattern extends StatelessWidget {
  const _DecorativePattern();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.42,
      child: Opacity(
        opacity: 0.15,
        child: CustomPaint(
          size: const Size(260, 170),
          painter: _RangoliPatternPainter(),
        ),
      ),
    );
  }
}

class _RangoliPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw decorative circles (rangoli-inspired)
    final paint = Paint()
      ..color = AppColors.saffron
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var ring = 0; ring < 3; ring++) {
      final r = 25.0 + ring * 22;
      canvas.drawCircle(center, r, paint);
    }

    // Draw diamond shapes
    final diamond = Paint()
      ..color = AppColors.magenta.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 4;
      final point = Offset(
        center.dx + math.cos(angle) * 60,
        center.dy + math.sin(angle) * 60,
      );
      canvas.drawCircle(point, 8, diamond);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeActionButton extends StatefulWidget {
  const _HomeActionButton({
    required this.filled,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool filled;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_HomeActionButton> createState() => _HomeActionButtonState();
}

class _HomeActionButtonState extends State<_HomeActionButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    final child = widget.filled
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: radius,
            ),
            child: _content(),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: widget.color, width: 1.5),
            ),
            child: _content(),
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(width: double.infinity, height: 56, child: child),
      ),
    );
  }

  Widget _content() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: widget.foreground, size: 22),
          const SizedBox(width: 10),
          Text(
            widget.label,
            style: TextStyle(
              color: widget.foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
