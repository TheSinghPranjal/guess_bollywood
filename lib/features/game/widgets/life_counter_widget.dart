import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class LifeCounterWidget extends StatelessWidget {
  const LifeCounterWidget({
    super.key,
    required this.wrongGuessCount,
    required this.configuredHints,
    this.extraLifeActive = false,
  });

  final int wrongGuessCount;
  final int configuredHints;
  final bool extraLifeActive;

  @override
  Widget build(BuildContext context) {
    final chars = AppConstants.lifeChars;

    return Column(
      children: [
        const Text(
          'BOLLY-WOOD',
          style: TextStyle(
            color: AppColors.saffronSoft,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          children: [
            for (var i = 0; i < chars.length; i++)
              _LifeChar(
                label: chars[i],
                struck: i < wrongGuessCount,
                hintTrigger: AppConstants.hintTriggerWrongCounts.contains(i + 1) &&
                    (AppConstants.hintTriggerWrongCounts.indexOf(i + 1) + 1) <=
                        configuredHints,
              ),
          ],
        ),
        if (extraLifeActive) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.magenta.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.magenta),
            ),
            child: const Text(
              'EXTRA LIFE ❤',
              style: TextStyle(
                color: AppColors.magenta,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LifeChar extends StatelessWidget {
  const _LifeChar({
    required this.label,
    required this.struck,
    required this.hintTrigger,
  });

  final String label;
  final bool struck;
  final bool hintTrigger;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: struck ? 0.45 : 1,
      child: Container(
        width: 28,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hintTrigger && !struck
              ? AppColors.emerald.withValues(alpha: 0.18)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: struck ? AppColors.error : AppColors.saffron.withValues(alpha: 0.4),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: struck ? AppColors.error : AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                decoration: struck ? TextDecoration.lineThrough : null,
                decorationThickness: 2.4,
                decorationColor: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
