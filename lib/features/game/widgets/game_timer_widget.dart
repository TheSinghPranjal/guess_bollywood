import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class GameTimerWidget extends StatelessWidget {
  const GameTimerWidget({
    super.key,
    required this.remaining,
    required this.unlimited,
    required this.urgent,
  });

  final Duration? remaining;
  final bool unlimited;
  final bool urgent;

  String get _label {
    if (unlimited || remaining == null) return '∞';
    final total = remaining!.inSeconds.clamp(0, 99999);
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.error : AppColors.saffronSoft;
    final child = Text(
      _label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
        fontSize: 20,
        letterSpacing: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );

    if (!urgent) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1.08),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      onEnd: () {},
      child: child,
    );
  }
}
