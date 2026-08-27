import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

enum KeyVisualState { available, correct, wrong, disabled }

class AlphabetKeyboard extends StatelessWidget {
  const AlphabetKeyboard({
    super.key,
    required this.correctLetters,
    required this.incorrectLetters,
    required this.enabled,
    required this.onLetterTap,
  });

  final Set<String> correctLetters;
  final Set<String> incorrectLetters;
  final bool enabled;
  final ValueChanged<String> onLetterTap;

  KeyVisualState _state(String letter) {
    if (correctLetters.contains(letter)) return KeyVisualState.correct;
    if (incorrectLetters.contains(letter)) return KeyVisualState.wrong;
    if (!enabled) return KeyVisualState.disabled;
    return KeyVisualState.available;
  }

  @override
  Widget build(BuildContext context) {
    final letters = AppConstants.consonants;
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 7;
        final spacing = 6.0;
        final width =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final letter in letters)
              _KeyButton(
                letter: letter,
                width: width.clamp(36, 52),
                state: _state(letter),
                onTap: () {
                  final state = _state(letter);
                  if (state == KeyVisualState.available) {
                    onLetterTap(letter);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.letter,
    required this.width,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final double width;
  final KeyVisualState state;
  final VoidCallback onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void didUpdateWidget(covariant _KeyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != KeyVisualState.wrong &&
        widget.state == KeyVisualState.wrong) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Color get _bg {
    switch (widget.state) {
      case KeyVisualState.available:
        return AppColors.keyboardKey;
      case KeyVisualState.correct:
        return AppColors.keyboardCorrect;
      case KeyVisualState.wrong:
        return AppColors.keyboardWrong;
      case KeyVisualState.disabled:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.state == KeyVisualState.available;
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final dx = _shake.isAnimating
            ? (1 - _shake.value) * 6 * ((_shake.value * 8).floor().isEven ? 1 : -1)
            : 0.0;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Material(
        color: _bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: interactive ? widget.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: widget.width,
            height: 44,
            child: Center(
              child: Text(
                widget.letter,
                style: TextStyle(
                  color: interactive || widget.state == KeyVisualState.correct
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  decoration: widget.state == KeyVisualState.wrong
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
