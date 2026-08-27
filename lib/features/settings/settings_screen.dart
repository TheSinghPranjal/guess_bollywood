import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final maxYear = AppConstants.maxYear;

    return Scaffold(
      body: MasalaBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('SETTINGS'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _SectionCard(
                      title: 'GAME TIMER',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final m in AppConstants.timerOptionsMinutes)
                            ChoiceChip(
                              label: Text(m == 0 ? 'Unlimited' : '$m min'),
                              selected: settings.timerMinutes == m,
                              onSelected: (_) => notifier.setTimerMinutes(m),
                              selectedColor: AppColors.saffron,
                              labelStyle: TextStyle(
                                color: settings.timerMinutes == m
                                    ? Colors.black
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: 'MOVIE ERA',
                      child: Column(
                        children: [
                          Text(
                            '${settings.startYear}  →  ${settings.resolvedEndYear}',
                            style: const TextStyle(
                              color: AppColors.saffronSoft,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          RangeSlider(
                            values: RangeValues(
                              settings.startYear.toDouble(),
                              settings.resolvedEndYear.toDouble(),
                            ),
                            min: AppConstants.minYear.toDouble(),
                            max: maxYear.toDouble(),
                            divisions: maxYear - AppConstants.minYear,
                            labels: RangeLabels(
                              '${settings.startYear}',
                              '${settings.resolvedEndYear}',
                            ),
                            onChanged: (v) {
                              notifier.setYearRange(
                                v.start.round(),
                                v.end.round(),
                              );
                            },
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('1990'),
                              Text('Now'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: 'HINTS',
                      child: Row(
                        children: [
                          for (var i = 0; i <= 4; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: ChoiceChip(
                                  label: Center(child: Text('$i')),
                                  selected: settings.hintCount == i,
                                  onSelected: (_) => notifier.setHintCount(i),
                                  selectedColor: AppColors.emerald,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: 'FEEDBACK',
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Sound'),
                            value: settings.soundEnabled,
                            onChanged: notifier.setSound,
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Haptics'),
                            value: settings.hapticsEnabled,
                            onChanged: notifier.setHaptics,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.saffronSoft,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
