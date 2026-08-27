import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_status.dart';
import '../../data/models/movie.dart';
import '../game/game_controller.dart';

Future<void> showWinDialog(BuildContext context, WidgetRef ref) {
  final session = ref.read(gameControllerProvider).session;
  if (session == null) return Future.value();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'You got it',
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _WinResultCard(
        title: session.movie.title,
        industry: session.movie.industry.label,
        year: session.movie.year,
        onNextRound: () async {
          Navigator.pop(dialogContext);
          await ref.read(gameControllerProvider.notifier).nextRound();
        },
        onHome: () {
          Navigator.pop(dialogContext);
          ref.read(gameControllerProvider.notifier).clearSession();
          Navigator.pop(context);
        },
      );
    },
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

Future<void> showLoseDialog(BuildContext context, WidgetRef ref) {
  final session = ref.read(gameControllerProvider).session;
  if (session == null) return Future.value();

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Game over',
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Consumer(
        builder: (consumerContext, ref, _) {
          final live = ref.watch(gameControllerProvider);
          final s = live.session;
          if (s == null) return const SizedBox.shrink();

          if (s.status == GameStatus.extraLifePlaying ||
              s.status == GameStatus.playing ||
              s.status == GameStatus.watchingRewardedAd) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            });
          }

          return _LoseResultCard(
            title: s.movie.title,
            adError: live.adErrorMessage,
            canWatchAd: s.canOfferRewardedLife,
            onWatchAd: () {
              ref.read(gameControllerProvider.notifier).watchRewardedAd();
            },
            onTryAgain: () {
              ref.read(gameControllerProvider.notifier).clearAdError();
              ref.read(gameControllerProvider.notifier).watchRewardedAd();
            },
            onNextRound: () async {
              Navigator.pop(dialogContext);
              await ref.read(gameControllerProvider.notifier).nextRound();
            },
            onHome: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).clearSession();
              Navigator.pop(context);
            },
          );
        },
      );
    },
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

Future<void> showPauseDialog(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('GAME PAUSED'),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).resume();
            },
            child: const Text('RESUME'),
          ),
          TextButton(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: dialogContext,
                builder: (c) => AlertDialog(
                  title: const Text('Restart this round?'),
                  content: const Text('Your current progress will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('RESTART'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                Navigator.pop(dialogContext);
                await ref.read(gameControllerProvider.notifier).startNewRound();
              }
            },
            child: const Text('RESTART'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(gameControllerProvider.notifier).clearSession();
              Navigator.pop(context);
            },
            child: const Text('EXIT TO HOME'),
          ),
        ],
      );
    },
  );
}

class _LoseResultCard extends StatelessWidget {
  const _LoseResultCard({
    required this.title,
    required this.adError,
    required this.canWatchAd,
    required this.onWatchAd,
    required this.onTryAgain,
    required this.onNextRound,
    required this.onHome,
  });

  final String title;
  final String? adError;
  final bool canWatchAd;
  final VoidCallback onWatchAd;
  final VoidCallback onTryAgain;
  final VoidCallback onNextRound;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final failed = adError != null;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D1218), Color(0xFF0D0808)],
                ),
                border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.9),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.28),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      failed ? 'REWARD FAILED' : 'GAME OVER',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.6,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 18,
                      width: double.infinity,
                      child: CustomPaint(painter: _SparkleDividerPainter()),
                    ),
                    const SizedBox(height: 18),
                    if (failed)
                      Text(
                        adError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      )
                    else ...[
                      const Text(
                        'The movie was:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _RevealedTitle(title: title),
                    ],
                    const SizedBox(height: 28),
                    if (failed) ...[
                      _SaffronFilledButton(label: 'TRY AGAIN', onTap: onTryAgain),
                      const SizedBox(height: 12),
                      _SaffronOutlineButton(label: 'END GAME', onTap: onHome),
                    ] else ...[
                      if (canWatchAd) ...[
                        _SaffronFilledButton(
                          label: 'WATCH AD +1 LIFE',
                          onTap: onWatchAd,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _SaffronOutlineButton(label: 'NEXT ROUND', onTap: onNextRound),
                      const SizedBox(height: 12),
                      _SaffronOutlineButton(label: 'HOME', onTap: onHome),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RevealedTitle extends StatelessWidget {
  const _RevealedTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _TitleSparklesPainter()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 1,
                color: AppColors.saffron.withValues(alpha: 0.55),
              ),
              const SizedBox(height: 10),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.saffronSoft, AppColors.saffron],
                ).createShader(bounds),
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: title.length > 14 ? 24 : 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: title.length > 14 ? 1.0 : 2.0,
                    height: 1.15,
                    shadows: [
                      Shadow(
                        color: AppColors.saffron.withValues(alpha: 0.6),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 160,
                height: 1,
                color: AppColors.saffron.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TitleSparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.saffron.withValues(alpha: 0.7);
    final dots = <Offset>[
      Offset(size.width * 0.12, size.height * 0.28),
      Offset(size.width * 0.22, size.height * 0.72),
      Offset(size.width * 0.78, size.height * 0.22),
      Offset(size.width * 0.88, size.height * 0.62),
      Offset(size.width * 0.08, size.height * 0.55),
      Offset(size.width * 0.92, size.height * 0.38),
    ];
    final radii = [2.2, 1.4, 2.0, 1.6, 1.2, 1.8];
    for (var i = 0; i < dots.length; i++) {
      canvas.drawCircle(dots[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SaffronFilledButton extends StatelessWidget {
  const _SaffronFilledButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.saffronSoft, AppColors.saffron],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SaffronOutlineButton extends StatelessWidget {
  const _SaffronOutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.saffron, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.saffron,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _WinResultCard extends StatelessWidget {
  const _WinResultCard({
    required this.title,
    required this.industry,
    required this.year,
    required this.onNextRound,
    required this.onHome,
  });

  final String title;
  final String industry;
  final int year;
  final VoidCallback onNextRound;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D1218), Color(0xFF0D0808)],
                ),
                border: Border.all(
                  color: AppColors.saffron.withValues(alpha: 0.9),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.28),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                      child: Column(
                        children: [
                          const Text(
                            'YOU GOT IT!',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.4,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.saffron,
                              fontSize: title.length > 14 ? 24 : 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  color: AppColors.saffron.withValues(alpha: 0.55),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$industry  •  $year',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.saffron.withValues(alpha: 0.28),
                    ),
                    SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          Expanded(
                            child: _FooterAction(
                              label: 'NEXT ROUND',
                              onTap: onNextRound,
                            ),
                          ),
                          VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: AppColors.saffron.withValues(alpha: 0.28),
                          ),
                          Expanded(
                            child: _FooterAction(
                              label: 'HOME',
                              onTap: onHome,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.saffron,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SparkleDividerPainter extends CustomPainter {
  const _SparkleDividerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final mid = size.width / 2;
    final line = Paint()
      ..strokeWidth = 1.15
      ..shader = LinearGradient(
        colors: [
          AppColors.saffron.withValues(alpha: 0),
          AppColors.saffron.withValues(alpha: 0.95),
          AppColors.saffron.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(8, cy), Offset(mid - 14, cy), line);
    canvas.drawLine(Offset(mid + 14, cy), Offset(size.width - 8, cy), line);

    final c = Offset(mid, cy);
    const r = 6.5;
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
    canvas.drawPath(path, Paint()..color = AppColors.saffron);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
