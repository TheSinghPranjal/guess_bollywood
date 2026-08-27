import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../engine/game_engine.dart';

class TitleMaskWidget extends StatelessWidget {
  const TitleMaskWidget({
    super.key,
    required this.cells,
    this.animateReveal = true,
  });

  final List<MaskCell> cells;
  final bool animateReveal;

  @override
  Widget build(BuildContext context) {
    final words = <List<MaskCell>>[];
    var current = <MaskCell>[];
    for (final cell in cells) {
      if (cell.type == MaskCellType.separator) {
        if (current.isNotEmpty) words.add(current);
        words.add([cell]);
        current = [];
      } else {
        current.add(cell);
      }
    }
    if (current.isNotEmpty) words.add(current);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 12,
      children: [
        for (final group in words)
          if (group.length == 1 && group.first.type == MaskCellType.separator)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '/',
                style: TextStyle(
                  color: AppColors.saffron,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Wrap(
              spacing: 6,
              children: [
                for (final cell in group) _LetterTile(cell: cell),
              ],
            ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({required this.cell});

  final MaskCell cell;

  @override
  Widget build(BuildContext context) {
    final revealed = cell.revealed;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      width: 28,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: revealed ? AppColors.saffronSoft : AppColors.textSecondary,
            width: 2,
          ),
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
          color: revealed ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        child: Text(revealed ? cell.display : '_'),
      ),
    );
  }
}
