import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class MasalaBackground extends StatelessWidget {
  const MasalaBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D1218),
            AppColors.background,
            Color(0xFF0D0808),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -40,
            child: _Glow(color: AppColors.saffron.withValues(alpha: 0.18), size: 220),
          ),
          Positioned(
            bottom: 80,
            right: -60,
            child: _Glow(color: AppColors.magenta.withValues(alpha: 0.14), size: 260),
          ),
          child,
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

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
          BoxShadow(color: color, blurRadius: 80, spreadRadius: 40),
        ],
      ),
    );
  }
}

class PressScaleButton extends StatefulWidget {
  const PressScaleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.saffron,
    this.foregroundColor = Colors.black,
    this.outlined = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool outlined;

  @override
  State<PressScaleButton> createState() => _PressScaleButtonState();
}

class _PressScaleButtonState extends State<PressScaleButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final child = widget.outlined
        ? OutlinedButton(
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: widget.foregroundColor,
              side: BorderSide(color: widget.backgroundColor, width: 1.5),
              minimumSize: const Size(double.infinity, 52),
            ),
            child: widget.child,
          )
        : ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: widget.child,
          );

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1),
      onTapCancel: () => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: child,
      ),
    );
  }
}
