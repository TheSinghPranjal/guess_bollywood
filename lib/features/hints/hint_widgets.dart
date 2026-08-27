import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class HintButton extends StatefulWidget {
  const HintButton({
    super.key,
    required this.visible,
    required this.blink,
    required this.onTap,
  });

  final bool visible;
  final bool blink;
  final VoidCallback onTap;

  @override
  State<HintButton> createState() => _HintButtonState();
}

class _HintButtonState extends State<HintButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant HintButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.blink && !oldWidget.blink) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
      ),
      child: FadeTransition(
        opacity: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1, end: 0.25), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.25, end: 1), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 1, end: 0.25), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.25, end: 1), weight: 1),
        ]).animate(_ctrl),
        child: Material(
          color: AppColors.saffron,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: AppColors.saffron.withValues(alpha: 0.6),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.lightbulb, color: Colors.black, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showHintDialog({
  required BuildContext context,
  required List<String> hints,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Hint',
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (context, animation, secondaryAnimation) =>
        HintDialog(hints: hints),
    transitionBuilder: (context, anim, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class HintDialog extends StatelessWidget {
  const HintDialog({super.key, required this.hints});

  final List<String> hints;

  static const Color _darkMaroon = Color(0xFF161326);
  static const Color _saffronBorder = Color(0xFFFF6F2C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 38),
                padding: const EdgeInsets.fromLTRB(22, 52, 22, 22),
                decoration: BoxDecoration(
                  color: _darkMaroon,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _saffronBorder.withValues(alpha: 0.85),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _saffronBorder.withValues(alpha: 0.22),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _HintTitle(),
                    const SizedBox(height: 18),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.38,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var i = 0; i < hints.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _HintCard(index: i + 1, text: hints[i]),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _GotItButton(),
                  ],
                ),
              ),
              const _LightbulbBadge(),
              Positioned(
                top: 46,
                right: 10,
                child: _CloseChip(onTap: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HintTitle extends StatelessWidget {
  const _HintTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _SaffronRule(reverse: true)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'HINT',
            style: TextStyle(
              color: AppColors.saffron,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
              fontFamily: 'serif',
              height: 1,
            ),
          ),
        ),
        Expanded(child: _SaffronRule()),
      ],
    );
  }
}

class _SaffronRule extends StatelessWidget {
  const _SaffronRule({this.reverse = false});

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reverse
              ? [AppColors.saffron.withValues(alpha: 0), AppColors.saffron]
              : [AppColors.saffron, AppColors.saffron.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1830),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.saffron.withValues(alpha: 0.55),
            ),
          ),
          child: Column(
            children: [
              Text(
                'Hint $index',
                style: const TextStyle(
                  color: AppColors.saffron,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          child: _FourPointStar(),
        ),
      ],
    );
  }
}

class _FourPointStar extends StatelessWidget {
  const _FourPointStar();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16, 16),
      painter: _SparklePainter(),
    );
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = -3.1415926535 / 2 + i * 3.1415926535 / 2;
      final outer = Offset(
        c.dx + math.cos(angle) * r,
        c.dy + math.sin(angle) * r,
      );
      final innerAngle = angle + 3.1415926535 / 4;
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
    canvas.drawPath(path, Paint()..color = AppColors.saffron);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LightbulbBadge extends StatelessWidget {
  const _LightbulbBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF161326),
        border: Border.all(color: AppColors.saffron, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffron.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.lightbulb,
        color: AppColors.saffronSoft,
        size: 36,
      ),
    );
  }
}

class _CloseChip extends StatelessWidget {
  const _CloseChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2540),
          border: Border.all(color: const Color(0x55FF6F2C)),
        ),
        child: const Icon(Icons.close, size: 16, color: Color(0xFFE8E0D2)),
      ),
    );
  }
}

class _GotItButton extends StatelessWidget {
  const _GotItButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.saffronSoft, AppColors.saffron],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'GOT IT',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
