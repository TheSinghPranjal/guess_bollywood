import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/game_status.dart';
import '../../services/ads/banner_ad_slot.dart';
import '../../widgets/common_widgets.dart';
import '../hints/hint_widgets.dart';
import '../result/result_dialogs.dart';
import 'game_controller.dart';
import 'widgets/alphabet_keyboard.dart';
import 'widgets/game_timer_widget.dart';
import 'widgets/life_counter_widget.dart';
import 'widgets/title_mask_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GameStatus? _lastStatus;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final session = state.session;

    ref.listen(gameControllerProvider, (prev, next) {
      final status = next.session?.status;
      if (status == null || status == _lastStatus) return;
      if (status == GameStatus.won) {
        _lastStatus = status;
        showWinDialog(context, ref);
      } else if (status == GameStatus.lost) {
        _lastStatus = status;
        showLoseDialog(context, ref);
      } else if (status == GameStatus.watchingRewardedAd ||
          status == GameStatus.adLoading) {
        _lastStatus = status;
      } else if (status == GameStatus.paused &&
          prev?.session?.status != GameStatus.paused) {
        _lastStatus = status;
        showPauseDialog(context, ref);
      } else if (status == GameStatus.playing ||
          status == GameStatus.extraLifePlaying) {
        _lastStatus = status;
      }
    });

    if (state.errorMessage != null && session == null) {
      return Scaffold(
        body: MasalaBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_creation_outlined,
                      size: 56, color: AppColors.saffron),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  PressScaleButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK TO SETTINGS'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (session == null) {
      return const Scaffold(
        body: MasalaBackground(
          child: Center(child: CircularProgressIndicator(color: AppColors.saffron)),
        ),
      );
    }

    final countdown = state.countdown;
    final showPlayUi = countdown == null && session.status != GameStatus.starting;
    final remaining = session.remainingTime;
    final urgent = remaining != null && remaining.inSeconds < 60;
    final canGuess = session.status.allowsGuesses;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await confirmLeave(context);
        if (leave && context.mounted) {
          controller.clearSession();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: MasalaBackground(
          child: Column(
            children: [
              Expanded(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final leave = await confirmLeave(context);
                                if (leave && context.mounted) {
                                  controller.clearSession();
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const Expanded(
                              child: Text(
                                'B-O-L-L-Y-W-O-O-D',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: AppColors.saffronSoft,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: canGuess ? controller.pause : null,
                              icon: const Icon(Icons.pause_circle_outline),
                            ),
                            GameTimerWidget(
                              remaining: remaining,
                              unlimited: remaining == null &&
                                  session.status != GameStatus.lost,
                              urgent: urgent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (countdown != null)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'GET READY...',
                                    style: TextStyle(
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '$countdown',
                                    style: const TextStyle(
                                      fontSize: 72,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.saffron,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          const Text(
                            'GUESS THE MOVIE',
                            style: TextStyle(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: TitleMaskWidget(cells: session.cells),
                            ),
                          ),
                          LifeCounterWidget(
                            wrongGuessCount:
                                session.wrongGuessCount.clamp(0, 10),
                            configuredHints: session.configuredHintCount,
                            extraLifeActive: session.extraLifeActive,
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: HintButton(
                              visible: session.hintButtonVisible && showPlayUi,
                              blink: state.hintJustUnlocked,
                              onTap: () async {
                                controller.openHint();
                                await showHintDialog(
                                  context: context,
                                  hints: session.unlockedHints,
                                );
                                controller.closeHint();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          AlphabetKeyboard(
                            correctLetters: session.correctLetters,
                            incorrectLetters: session.incorrectLetters,
                            enabled: canGuess,
                            onLetterTap: controller.guess,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (showPlayUi) const BannerAdSlot(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmLeave(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Leave game?'),
      content: const Text('Your current progress will be lost.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CONTINUE PLAYING'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('EXIT'),
        ),
      ],
    ),
  );
  return result ?? false;
}
